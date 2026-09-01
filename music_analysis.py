#!/usr/bin/env python3
"""original_musics/{曲名}.mp3 を解析して、
analyzed_music_data/data_{曲名}.py に file_path / beat_times / brightness / smoothness を書き込む。

使い方:
    python3 music_analysis.py -f "オリジナル音源(mp3形式)の相対パス" [--lang ja|en]

依存パッケージ（未インストールの場合は事前に用意すること）:
    sudo apt install ffmpeg
    pip3 install spleeter librosa pydub SpeechRecognition transformers torch
"""
import argparse
import os
import re
import subprocess
import sys

import numpy as np

SCRIPT_DIR = os.path.dirname(os.path.abspath(__file__))
DATA_DIR = os.path.join(SCRIPT_DIR, "analyzed_music_data")
SEPARATED_DIR = os.path.join(SCRIPT_DIR, "separated_audio")


# =============================
# 音源分離（spleeter）
# =============================
def separate_stems(mp3_path, song_name):
    """vocals/drums/other/bass の4stemに分離し、そのディレクトリを返す"""
    out_dir = os.path.join(SEPARATED_DIR, song_name)
    stems_dir = os.path.join(out_dir, os.path.splitext(os.path.basename(mp3_path))[0])
    if not os.path.exists(os.path.join(stems_dir, "drums.wav")):
        subprocess.run(
            ["spleeter", "separate", "-o", out_dir, "-p", "spleeter:4stems-16kHz", mp3_path],
            check=True,
        )
    return stems_dir


# =============================
# 無音開始検出（曲が実際に鳴り始める時間を推定）
# =============================
def detect_audio_start_time(audio_file, silence_threshold=-40.0, chunk_ms=10):
    from pydub import AudioSegment

    ext = os.path.splitext(audio_file)[1].lstrip(".").lower()
    audio = AudioSegment.from_file(audio_file, format=ext)

    for i in range(0, len(audio), chunk_ms):
        if audio[i:i + chunk_ms].dBFS > silence_threshold:
            return i / 1000.0
    return 0.0


# =============================
# ビート検出（曲開始前も予測）
# =============================
def detect_beat_positions(drums_wav_file, tempo_multiplier=2, audio_start_time=0.0):
    import librosa

    y, sr = librosa.load(drums_wav_file, sr=None)
    onset_env = librosa.onset.onset_strength(y=y, sr=sr)
    tempo = librosa.beat.tempo(onset_envelope=onset_env, sr=sr)[0]

    while tempo > 100:
        tempo /= 2
    adjusted_tempo = tempo * tempo_multiplier

    beat_frames = librosa.beat.beat_track(onset_envelope=onset_env, sr=sr)[1]
    beat_times = librosa.frames_to_time(beat_frames, sr=sr)

    # 間隔フィルタリング
    filtered_beats = []
    min_interval = 0.9 * 60.0 / adjusted_tempo
    previous_time = -np.inf
    for t in beat_times:
        if t - previous_time >= min_interval:
            filtered_beats.append(float(t))
            previous_time = t

    # 曲開始前の予測ビート（最初の検出ビートより前を平均間隔で逆算）
    if filtered_beats and filtered_beats[0] > audio_start_time:
        if len(filtered_beats) > 1:
            avg_interval = float(np.mean(np.diff(filtered_beats)))
        else:
            avg_interval = 60.0 / adjusted_tempo

        predicted = []
        t = filtered_beats[0] - avg_interval
        while t >= audio_start_time:
            predicted.insert(0, t)
            t -= avg_interval
        filtered_beats = predicted + filtered_beats

    return filtered_beats


# =============================
# brightness（歌詞の感情分析）
# =============================
def transcribe_lyrics(vocals_wav_file, lang="ja", start_sec=20, end_sec=80):
    import speech_recognition as sr
    from pydub import AudioSegment

    audio = AudioSegment.from_wav(vocals_wav_file)
    clip = audio[start_sec * 1000:end_sec * 1000]

    tmp_path = os.path.join(SEPARATED_DIR, "_tmp_lyrics.wav")
    os.makedirs(SEPARATED_DIR, exist_ok=True)
    clip.export(tmp_path, format="wav")
    try:
        recognizer = sr.Recognizer()
        with sr.AudioFile(tmp_path) as source:
            audio_data = recognizer.record(source)
        lang_code = "ja-JP" if lang == "ja" else "en-US"
        return recognizer.recognize_google(audio_data, language=lang_code)
    except sr.UnknownValueError:
        print("    (歌詞を認識できませんでした。インストゥルメンタル曲か、聞き取りにくい可能性があります)")
        return ""
    except sr.RequestError as e:
        print(f"    (音声認識サービスへの接続に失敗しました: {e})")
        return ""
    finally:
        if os.path.exists(tmp_path):
            os.remove(tmp_path)


def analyze_brightness(lyrics_text, lang="ja"):
    """歌詞の感情を signed float で返す（negativeなら負、positive/neutralなら正）"""
    from transformers import pipeline, AutoModelForSequenceClassification, BertJapaneseTokenizer

    if not lyrics_text.strip():
        return 0.0

    if lang == "ja":
        model = AutoModelForSequenceClassification.from_pretrained(
            "koheiduck/bert-japanese-finetuned-sentiment"
        )
        tokenizer = BertJapaneseTokenizer.from_pretrained(
            "cl-tohoku/bert-base-japanese-whole-word-masking"
        )
        analyzer = pipeline("sentiment-analysis", model=model, tokenizer=tokenizer)
    else:
        analyzer = pipeline(
            "sentiment-analysis", model="distilbert-base-uncased-finetuned-sst-2-english"
        )

    result = analyzer(lyrics_text)[0]
    score = result["score"]
    return -score if result["label"].lower().startswith("neg") else score


# =============================
# smoothness（伴奏(other)の振幅変化）
# =============================
def calculate_amplitude_change(other_wav_file, duration=30, peak_freq_range=(500, 2000), interval_ms=100):
    """
    指定されたWAVファイルの冒頭30秒に対して500Hzから2000Hzの範囲内で振幅の変化量を計算。
    振幅の変化量は、100ミリ秒単位で計算し、変化の絶対値を足し合わせて、最大振幅で正規化する。
    """
    from pydub import AudioSegment
    from scipy.fftpack import fft

    audio = AudioSegment.from_wav(other_wav_file)
    samples = np.array(audio.get_array_of_samples())
    sampling_rate = audio.frame_rate
    samples = samples[: int(duration * sampling_rate)]

    def amplitude_spectrum(segment):
        result = fft(segment)
        freqs = np.fft.fftfreq(len(segment), d=1 / sampling_rate)
        half = len(result) // 2
        return freqs[:half], np.abs(result[:half])

    changes = []
    peaks = []
    prev = None
    step = int(sampling_rate * interval_ms / 1000)
    for start in range(0, len(samples), step):
        segment = samples[start:start + step]
        freqs, spectrum = amplitude_spectrum(segment)
        mask = (freqs >= peak_freq_range[0]) & (freqs <= peak_freq_range[1])
        peak = np.sum(spectrum[mask])
        if prev is not None:
            changes.append(np.abs(peak - prev))
            peaks.append(peak)
        prev = peak

    max_peak = max(peaks) if peaks else 1
    normalized = [c / max_peak for c in changes]
    amplitude_change_sum = min(np.sum(normalized) / duration, 0.9)
    return float(min(-np.log(amplitude_change_sum) * 2, 0.9))


# =============================
# data_<曲名>.py への書き込み（beat_pose_dictionary など既存の内容は保持）
# =============================
def _write_field(text, name, value_repr):
    pattern = re.compile(rf"^{name}\s*=.*$", re.M)
    line = f"{name} = {value_repr}"
    if pattern.search(text):
        return pattern.sub(line, text, count=1)
    if not text.endswith("\n"):
        text += "\n"
    return text + line + "\n"


def write_analysis_result(data_path, file_path, beat_times, brightness, smoothness):
    text = open(data_path, encoding="utf-8").read() if os.path.exists(data_path) else ""
    text = _write_field(text, "file_path", repr(file_path))
    text = _write_field(text, "beat_times", repr([round(t, 3) for t in beat_times]))
    text = _write_field(text, "brightness", repr(round(brightness, 4)))
    text = _write_field(text, "smoothness", repr(round(smoothness, 4)))
    with open(data_path, "w", encoding="utf-8") as f:
        f.write(text)


def main():
    parser = argparse.ArgumentParser(description="音源を解析し data_<曲名>.py に書き込む")
    parser.add_argument("-f", "--file", required=True, help="オリジナル音源(mp3形式)の相対パス")
    parser.add_argument("--lang", choices=["ja", "en"], default="ja", help="歌詞の言語（デフォルト: ja）")
    args = parser.parse_args()

    mp3_path = os.path.abspath(args.file)
    if not os.path.exists(mp3_path):
        print(f"Error: {mp3_path} が見つかりません。")
        sys.exit(1)

    song_name = os.path.splitext(os.path.basename(mp3_path))[0]
    data_path = os.path.join(DATA_DIR, f"data_{song_name}.py")

    print(f">>> {song_name}: 音源分離 (spleeter) ...")
    stems_dir = separate_stems(mp3_path, song_name)

    print(">>> ビート検出 ...")
    audio_start = detect_audio_start_time(mp3_path)
    beat_times = detect_beat_positions(
        os.path.join(stems_dir, "drums.wav"), audio_start_time=audio_start
    )
    print(f"    {len(beat_times)} 拍検出（曲の開始時刻: {audio_start:.3f}秒）")

    lang_label = "日本語" if args.lang == "ja" else "英語"
    print(f">>> 歌詞の明るさ(brightness)分析 ... (歌詞の言語: {lang_label})")
    vocals_wav = os.path.join(stems_dir, "vocals.wav")
    # まず開始20秒後〜80秒後で歌詞抽出。認識できなければ80秒後〜110秒後で再実行する。
    lyrics = transcribe_lyrics(vocals_wav, lang=args.lang, start_sec=20, end_sec=80)
    if not lyrics.strip():
        print("    20〜80秒で認識できなかったため、80〜110秒で再実行します ...")
        lyrics = transcribe_lyrics(vocals_wav, lang=args.lang, start_sec=80, end_sec=110)
    if lyrics.strip():
        print(f"    抽出された歌詞: {lyrics}")
    brightness = analyze_brightness(lyrics, lang=args.lang)
    print(f"    brightness = {brightness:.4f}")

    print(">>> 伴奏の滑らかさ(smoothness)分析 ...")
    smoothness = calculate_amplitude_change(os.path.join(stems_dir, "other.wav"))
    print(f"    smoothness = {smoothness:.4f}")

    os.makedirs(DATA_DIR, exist_ok=True)
    write_analysis_result(data_path, mp3_path, beat_times, brightness, smoothness)
    print(f"{data_path} に書き込みました。")


if __name__ == "__main__":
    main()
