import os
import importlib
import shutil
import tkinter as tk
import subprocess
from tkinter import ttk, filedialog, messagebox

SCRIPT_DIR = os.path.dirname(os.path.abspath(__file__))
MUSIC_DIR = os.path.join(SCRIPT_DIR, "original_musics")
DANCE_DATA_PATH = "/tmp/data.l"
# 実機起動(minimal.launch)〜コントローラが動かせる状態になるまでの目安の待ち時間。
# Gazeboと違い物理シミュレーションの起動を待つ必要がないため短め。
# マシン/実機によっては足りない/長すぎる場合があるので必要に応じて調整すること。
ROBOT_STARTUP_DELAY_MS = 5000


# 「新しい曲のダンスを生成」でmp3を選ぶファイルダイアログの初期ディレクトリ候補。
# Docker/distroboxではホストのダウンロードフォルダがそのままでは見えないため、
# コンテナ内にマウントしたホスト側ディレクトリ(/host/*)を最優先で探す。
_MUSIC_DIALOG_DIRS = (
    "/host/Music", "/host/Downloads", "/host",
    os.path.expanduser("~/Music"), os.path.expanduser("~/Downloads"),
    os.path.expanduser("~/ダウンロード"), os.path.expanduser("~/ミュージック"),
    os.path.expanduser("~"),
)


def _default_music_dir():
    existing = [d for d in _MUSIC_DIALOG_DIRS if d and os.path.isdir(d)]
    # まずmp3が実際に入っているディレクトリを優先（空のMusicフォルダ等を避ける）
    for d in existing:
        try:
            if any(f.lower().endswith(".mp3") for f in os.listdir(d)):
                return d
        except OSError:
            pass
    return existing[0] if existing else SCRIPT_DIR


def _existing_song_names():
    """original_musicsフォルダに既にあるmp3から曲名(拡張子抜き)の集合を作る"""
    if not os.path.isdir(MUSIC_DIR):
        return set()
    return {
        os.path.splitext(f)[0]
        for f in os.listdir(MUSIC_DIR)
        if f.lower().endswith(".mp3")
    }


# UI起動前にROSの環境をsourceし、以降のsubprocessにも引き継がせる
def load_ros_env():
    result = subprocess.run(
        ["bash", "-c", "source ~/ros/enshu_ws/devel/setup.bash && env -0"],
        capture_output=True, check=True
    )
    for entry in result.stdout.decode().split("\0"):
        if "=" in entry:
            key, _, value = entry.partition("=")
            os.environ[key] = value

load_ros_env()

# analyzed_music_data/data_<曲名>.py の値を euslisp から読める /tmp/data.l に書き出す
def _to_lisp(value):
    if isinstance(value, (list, tuple)):
        return "(" + " ".join(_to_lisp(v) for v in value) + ")"
    return repr(value)

def write_dance_data_lisp(music_name, output_path=DANCE_DATA_PATH):
    data = importlib.import_module(f"analyzed_music_data.data_{music_name}")
    with open(output_path, "w") as f:
        f.write(f"(defparameter *beat-times* '{_to_lisp(data.beat_times)})\n")
        f.write(f"(defparameter *smoothness* {data.smoothness})\n")
        f.write(f"(defparameter *beat-pose-dictionary* '{_to_lisp(data.beat_pose_dictionary)})\n")

# ウィンドウ作成
root = tk.Tk()
root.title("Dancing_Jedy (実機)")
root.geometry("1500x1280")

# 背景画像の読み込み
background_image = tk.PhotoImage(file="drum-set-1839383_1920 (2).png")

# 背景画像をLabelにして貼り付け
bg_label = tk.Label(root, image=background_image)
bg_label.place(x=0, y=0, relwidth=1, relheight=1)

style = ttk.Style()
style.configure("TCombobox", font=("Helvetica", 24))  # フォントサイズを24に設定
# プルダウンメニューの選択肢をリストにする（original_musicsフォルダにあるものを全表示）
options = sorted(_existing_song_names())
combo = ttk.Combobox(root, values=options, state="readonly")
if "ダンスホール" in options:
    combo.set("ダンスホール")  # デフォルト
elif options:
    combo.set(options[0])
combo.pack(pady=20)

# 選択表示の確認用（なくても動作する）
def on_select(event):
    selected_option = combo.get()
    print(f"選択された曲: {selected_option}")

combo.bind("<<ComboboxSelected>>", on_select)

# 各ボタンが呼び出す関数
def generate_new_dance():
    print("新しいダンススクリプトを生成")
    # ローカルのmp3ファイルを１つ選択してもらい、それをoriginal_musicsフォルダにコピーして、original_musicsフォルダの方のパスをnew_musicとして保持
    selected_path = filedialog.askopenfilename(
        title="mp3ファイルを選択してください",
        initialdir=_default_music_dir(),
        filetypes=[("MP3 files", "*.mp3")],
    )
    if not selected_path:
        print("ファイルが選択されませんでした")
        return

    song_name = os.path.splitext(os.path.basename(selected_path))[0]

    # 既存の曲名と同じ場合は上書き（mp3・解析済みデータ・振り付けの消失）になるため確認する
    if song_name in _existing_song_names():
        proceed = messagebox.askyesno(
            "確認",
            f"「{song_name}」は既存の曲と同じファイル名です。\n"
            "続行すると元のmp3ファイルと解析済みデータ（ビート・明るさ・振り付け等）が"
            "上書きされる可能性があります。\n続行しますか？",
        )
        if not proceed:
            print(f"「{song_name}」は既存の曲と同名のため中止しました")
            return

    os.makedirs(MUSIC_DIR, exist_ok=True)
    dest_path = os.path.join(MUSIC_DIR, os.path.basename(selected_path))
    shutil.copy(selected_path, dest_path)
    new_music = os.path.relpath(dest_path, SCRIPT_DIR)
    print(f"{selected_path} を {dest_path} にコピーしました")

    # music_analysis.py が beat_times/smoothness/brightness を書き込んだ後でないと
    # dance_generation.py が動かないため、新しいターミナルで逐次実行する。
    # 両方成功した時だけ marker ファイルを作り、曲一覧への追加はそれを確認してから行う。
    marker_path = f"/tmp/dance_generation_done_{song_name}"
    if os.path.exists(marker_path):
        os.remove(marker_path)
    subprocess.Popen(["gnome-terminal", "--", "bash", "-c",
        f'python3 music_analysis.py -f "{new_music}" && '
        f'python3 dance_generation.py -f "{new_music}" && '
        f'touch "{marker_path}"; exec bash'])
    _wait_for_new_dance(song_name, marker_path)


def _wait_for_new_dance(song_name, marker_path):
    """marker_pathが作られる(=解析・生成が両方成功する)まで待ち、曲一覧に追加する"""
    if os.path.exists(marker_path):
        os.remove(marker_path)
        if song_name not in combo["values"]:
            combo["values"] = (*combo["values"], song_name)
        print(f"{song_name} の生成が完了したので曲一覧に追加しました")
        return
    root.after(2000, lambda: _wait_for_new_dance(song_name, marker_path))

def setup_dance_scripts(music_name):
    print(f"Lispスクリプト2本を起動（{music_name}）")
    write_dance_data_lisp(music_name)
    subprocess.Popen(["gnome-terminal", "--", "bash", "-c", "roseus real_dance/jedy_dance_subscribe.l; exec bash"])
    subprocess.Popen(["gnome-terminal", "--", "bash", "-c", "roseus real_dance/wheel_move_dance.l; exec bash"])
    # ダンス準備が完了したので「ダンススタート」を押せるようにする
    _set_start_button_ready(True)

def prepare_dance(music_name):
    """実機の起動とダンススクリプトの準備をまとめて行う"""
    # 準備が完了するまでは「ダンススタート」を押せないようにする
    _set_start_button_ready(False)
    print("新しいターミナルで minimal.launch を実行")
    subprocess.Popen(["gnome-terminal", "--", "bash", "-c", "roslaunch jedy_bringup minimal.launch; exec bash"])
    # コントローラが立ち上がりきる前にダンススクリプトを動かすと失敗するので、
    # 少し待ってから setup_dance_scripts を呼ぶ（GUIをブロックしないよう root.after で遅延）
    root.after(ROBOT_STARTUP_DELAY_MS, lambda: setup_dance_scripts(music_name))

def play_music(music_name):
    print("音楽を再生中")
    subprocess.Popen(["python3", "music_publish.py", f"{music_name}"])

def stop_music_and_ros():
    """音楽と実機のROS(ダンス/ホイールスクリプト含む)をまとめて停止し、次の曲のために状態をクリアする"""
    print("音楽とROSを停止")
    subprocess.Popen(["pkill", "-9", "-f", "music_publish.py"])
    subprocess.Popen(["pkill", "-9", "-f", "ros"])
    subprocess.run(["pkill", "-f", "jedy_dance_subscribe.l"])
    subprocess.run(["pkill", "-f", "wheel_move_dance.l"])
    # 今の曲のポーズ司令情報を消しておき、次に選んだ曲のものに確実に書き換わるようにする
    if os.path.exists(DANCE_DATA_PATH):
        os.remove(DANCE_DATA_PATH)
    # 停止したので、次に「ダンス準備」が完了するまで「ダンススタート」は押せない
    _set_start_button_ready(False)

# ボタンのスタイル
button_style = {
    "bg": "black",
    "fg": "white",
    "activebackground": "gray20",
    "activeforeground": "white",
    "borderwidth": 0,
    "highlightthickness": 0
}

# 「ダンススタート」用: 押せない間(非アクティブ)/押せる間(アクティブ)で色を変える
button_style_start_inactive = {
    "bg": "gray30",
    "fg": "gray60",
    "activebackground": "gray30",
    "activeforeground": "gray60",
    "borderwidth": 0,
    "highlightthickness": 0,
}
button_style_start_active = {
    "bg": "green4",
    "fg": "white",
    "activebackground": "green3",
    "activeforeground": "white",
    "borderwidth": 0,
    "highlightthickness": 0,
}

# 各ボタン（ラムダ式で引数を渡す）
btn1 = tk.Button(root, text="ダンス準備", command=lambda: prepare_dance(combo.get()), **button_style)
btn1.place(x=600, y=100, width=300, height=150)

# 「ダンススタート」は「ダンス準備」の完了後にしか押せないようにする（初期状態は非アクティブ）
btn2 = tk.Button(root, text="ダンススタート", command=lambda: play_music(combo.get()),
                  state=tk.DISABLED, **button_style_start_inactive)
btn2.place(x=600, y=300, width=300, height=150)

def _set_start_button_ready(ready):
    if ready:
        btn2.config(state=tk.NORMAL, **button_style_start_active)
    else:
        btn2.config(state=tk.DISABLED, **button_style_start_inactive)

btn3 = tk.Button(root, text="音楽終了", command=stop_music_and_ros, **button_style)
btn3.place(x=600, y=500, width=300, height=150)

btn4 = tk.Button(root, text="新しい曲のダンスを生成", command=generate_new_dance, **button_style)
btn4.place(x=600, y=700, width=300, height=150)

root.mainloop()
