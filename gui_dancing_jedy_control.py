import tkinter as tk
import subprocess  # 外部コマンドを実行する場合に使用

# ウィンドウ作成
root = tk.Tk()
root.title("Dancing_Jedy")
root.geometry("1500x1280")

# 背景画像の読み込み
background_image = tk.PhotoImage(file="drum-set-1839383_1920 (2).png")

# 背景画像をLabelにして貼り付け（placeでサイズ指定＆固定）
bg_label = tk.Label(root, image=background_image)
bg_label.place(x=0, y=0, relwidth=1, relheight=1)

# --- ローカル関数・コマンド定義 ---
def run_local_script1():
    print("ローカル処理1を実行")
    subprocess.Popen(["python3", "music_publish.py","カメレオン"])

def run_local_script2():
    print("ローカル処理2を実行")
    subprocess.Popen(["python3", "music_publish.py","ダンスホール"])

def run_local_script3():
    print("stop all music")
    subprocess.Popen(["pkill", "-9", "-f", "music_publish.py"])

def run_local_script4():
    print("新しいターミナルで ROS コマンドを実行")
    # 新しいターミナルを立ち上げてROSコマンドを実行
    subprocess.Popen(["gnome-terminal", "--", "bash", "-c", "source ~/ros/enshu_ws/devel/setup.bash; roslaunch jedy_bringup minimal.launch; exec bash"])

def shutdown_ros():
    print("ROSを終了")
    # ROS関連プロセスを全てkill（roscore, roslaunch など）
    subprocess.Popen(["pkill", "-9", "-f", "ros"])
    # 必要に応じてノード名やlaunchファイル名でも個別kill可能

def setup_chameleon_scripts():
    print("Lispスクリプト2本を起動（カメレオン）")
    subprocess.Popen(["gnome-terminal", "--", "bash", "-c", "roseus jedy_dance_subscribe_カメレオン.l; exec bash"])
    subprocess.Popen(["gnome-terminal", "--", "bash", "-c", "roseus wheel_move_dance_カメレオン.l; exec bash"])

def stop_chameleon_all():
    print("カメレオン関連のすべてのプロセスを停止")
    subprocess.run(["pkill", "-f", "jedy_dance_subscribe_カメレオン.l"])
    subprocess.run(["pkill", "-f", "wheel_move_dance_カメレオン.l"])
    subprocess.run(["pkill", "-f", "music_publish.py"])


# --- ボタン設定 ---
# 黒背景・白文字・目立たない感じ
button_style = {
    "bg": "black",
    "fg": "white",
    "activebackground": "gray20",
    "activeforeground": "white",
    "borderwidth": 0,
    "highlightthickness": 0
}

btn1 = tk.Button(root, text="再生：カメレオン", command=run_local_script1, **button_style)
btn1.place(x=600, y=100, width=300, height=150)

btn2 = tk.Button(root, text="再生：ダンスホール", command=run_local_script2, **button_style)
btn2.place(x=600, y=300, width=300, height=150)

btn3 = tk.Button(root, text="音楽をすべて停止", command=run_local_script3, **button_style)
btn3.place(x=600, y=500, width=300, height=150)

btn4 = tk.Button(root, text="ROSを起動", command=run_local_script4, **button_style)
btn4.place(x=600, y=700, width=300, height=150)

btn5 = tk.Button(root, text="ROSを終了", command=shutdown_ros, **button_style)
btn5.place(x=600, y=900, width=300, height=150)

btn_setup = tk.Button(root, text="カメレオン準備", command=setup_chameleon_scripts, **button_style)
btn_setup.place(x=100, y=1100, width=300, height=100)

btn_stop = tk.Button(root, text="カメレオン停止", command=stop_chameleon_all, **button_style)
btn_stop.place(x=900, y=1100, width=300, height=100)

root.mainloop()