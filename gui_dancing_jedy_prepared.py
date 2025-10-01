import tkinter as tk
import subprocess
from tkinter import ttk


# ウィンドウ作成
root = tk.Tk()
root.title("Dancing_Jedy")
root.geometry("1500x1280")

# 背景画像の読み込み
background_image = tk.PhotoImage(file="drum-set-1839383_1920 (2).png")

# 背景画像をLabelにして貼り付け
bg_label = tk.Label(root, image=background_image)
bg_label.place(x=0, y=0, relwidth=1, relheight=1)

style = ttk.Style()
style.configure("TCombobox", font=("Helvetica", 24))  # フォントサイズを24に設定
# プルダウンメニューの選択肢をリストにする
options = ["カメレオン", "ダンスホール", "愛をこめて花束を", "firework", "permission_to_dance", "もうええわ", "ライラック", "紅蓮華","APT"]
combo = ttk.Combobox(root, values=options, state="readonly")
combo.set("ダンスホール")  # デフォルト値
combo.pack(pady=20)

# 選択表示の確認用（なくても動作する）
def on_select(event):
    selected_option = combo.get()
    print(f"選択された曲: {selected_option}")

combo.bind("<<ComboboxSelected>>", on_select)

# 各ボタンが呼び出す関数
def start_ros():
    print("新しいターミナルで minimal.launch を実行")
    subprocess.Popen(["gnome-terminal", "--", "bash", "-c", "source ~/ros/enshu_ws/devel/setup.bash; roslaunch jedy_bringup minimal.launch; exec bash"])

def setup_dance_scripts(music_name):
    print(f"Lispスクリプト2本を起動（{music_name}）")
    subprocess.Popen(["gnome-terminal", "--", "bash", "-c", f"source ~/ros/enshu_ws/devel/setup.bash; roseus jedy_dance_subscribe_{music_name}.l; exec bash"])
    subprocess.Popen(["gnome-terminal", "--", "bash", "-c", f"source ~/ros/enshu_ws/devel/setup.bash; roseus wheel_move_dance_{music_name}.l; exec bash"])

def play_music(music_name):
    print("音楽を再生中")
    subprocess.Popen(["python3", "music_publish.py", f"{music_name}"])

def stop_music():
    print("音楽を停止")
    subprocess.Popen(["pkill", "-9", "-f", "music_publish.py"])

def stop_ros(music_name):
    print("ROSを停止")    
    subprocess.Popen(["pkill", "-9", "-f", "ros"])
    subprocess.run(["pkill", "-f", f"jedy_dance_subscribe_{music_name}.l"])
    subprocess.run(["pkill", "-f", f"wheel_move_dance_{music_name}.l"])

# ボタンのスタイル
button_style = {
    "bg": "black",
    "fg": "white",
    "activebackground": "gray20",
    "activeforeground": "white",
    "borderwidth": 0,
    "highlightthickness": 0
}

# 各ボタン（ラムダ式で引数を渡す）
btn1 = tk.Button(root, text="ROSを起動", command=start_ros, **button_style)
btn1.place(x=600, y=100, width=300, height=150)

btn2 = tk.Button(root, text="ダンス準備", command=lambda: setup_dance_scripts(combo.get()), **button_style)
btn2.place(x=600, y=300, width=300, height=150)

btn3 = tk.Button(root, text="ダンススタート", command=lambda: play_music(combo.get()), **button_style)
btn3.place(x=600, y=500, width=300, height=150)

btn4 = tk.Button(root, text="音楽終了", command=stop_music, **button_style)
btn4.place(x=600, y=700, width=300, height=150)

btn5 = tk.Button(root, text="ROS終了", command=lambda: stop_ros(combo.get()), **button_style)
btn5.place(x=600, y=900, width=300, height=150)

root.mainloop()
