import pygame
from pynput import keyboard
import time
import os
import threading

# 再生、停止、スキップの制御を行う関数
def audio_player(file_path):
    """
    与えられた音声ファイルの再生を開始し、ユーザー入力を監視して操作（停止、再生、スキップ等）を行う。

    :param file_path: 音楽ファイルのパス (MP3フォーマット)
    """
    # 初期化とエラーチェック
    if not os.path.exists(file_path):
        print(f"Error: File '{file_path}' not found.")
        return

    pygame.mixer.init()  # pygameのミキサーを初期化
    try:
        pygame.mixer.music.load(file_path)
        pygame.mixer.music.play()
        print("Music playing started.")
    except pygame.error as e:
        print(f"Error loading or playing the file: {e}")
        return

    paused = False
    try:
        # 音声ファイルの長さを取得
        duration = pygame.mixer.Sound(file_path).get_length()
        print(f"Duration of the track: {duration:.2f} seconds.")
    except pygame.error as e:
        print(f"Error getting file duration: {e}")
        duration = float('inf')

    # 音楽の進行状況を1秒ごとに表示するスレッド関数
    def log_current_position():
        """
        音楽の現在の位置を毎秒表示するスレッド関数。音楽が再生中であれば1秒ごとに現在の位置をログに出力。
        """
        while pygame.mixer.music.get_busy():  # 音楽が再生中の場合
            current_pos = pygame.mixer.music.get_pos() / 1000  # ミリ秒を秒に変換
            print(f"Current position: {current_pos:.2f} seconds")
            time.sleep(1)

    # 音楽の進行ログを1秒ごとに出力するスレッドの開始
    threading.Thread(target=log_current_position, daemon=True).start()

    # 音楽再生中にキーボード入力を待機
    def on_press(key):
        nonlocal paused
        try:
            if hasattr(key, 'char') and key.char is not None:
                key_pressed = key.char.lower()

                if key_pressed == ' ':
                    # Pause/Unpause 操作
                    if paused:
                        pygame.mixer.music.unpause()
                        print("Resumed")
                    else:
                        pygame.mixer.music.pause()
                        print("Paused")
                    paused = not paused

                # 右矢印キー (進む)
                elif key_pressed == 'd':
                    # 音楽が再生中であることを確認
                    if pygame.mixer.music.get_busy():
                        current_pos = pygame.mixer.music.get_pos() / 1000  # ミリ秒を秒に変換
                        new_pos = current_pos + 10  # 現在位置から10秒進む
                        if new_pos > duration:  # Durationを超えて進めないようにする
                            new_pos = duration
                        pygame.mixer.music.set_pos(new_pos)
                        print(f"Forward 10 seconds. New position: {new_pos:.2f} seconds")

                # 左矢印キー (戻る)
                elif key_pressed == 'a':
                    # 音楽が再生中であることを確認
                    if pygame.mixer.music.get_busy():
                        current_pos = pygame.mixer.music.get_pos() / 1000  # ミリ秒を秒に変換
                        new_pos = current_pos - 10  # 現在位置から10秒戻る
                        if new_pos < 0:  # 0秒以下にしないようにする
                            new_pos = 0
                        pygame.mixer.music.set_pos(new_pos)
                        print(f"Rewind 10 seconds. New position: {new_pos:.2f} seconds")

                # ESCキーで停止
                elif key == keyboard.Key.esc:
                    pygame.mixer.music.stop()
                    print("Stopped")
                    return False  # Stop the listener

        except AttributeError:
            # 不正なキーイベントを処理
            pass

    # キーボードリスナーを作成して、入力を監視
    with keyboard.Listener(on_press=on_press) as listener:
        listener.join()

if __name__ == "__main__":
    file_path = input("Enter the path of the MP3 file: ")
    audio_player(file_path)
