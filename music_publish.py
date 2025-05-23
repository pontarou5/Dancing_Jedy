import rospy
from std_msgs.msg import Float64
import vlc
import time
import os
from pynput import keyboard
import threading
import sys

# コマンドライン引数でファイルを選択
if len(sys.argv) > 1:
    data_file = sys.argv[1]  # 引数で指定されたファイル名

    if data_file == "ダンスホール":
        import ダンスホール_data as data
    elif data_file == "カメレオン":
        import カメレオン_data as data
    else:
        raise ValueError(f"Unknown data file: {data_file}")

    file_path = data.file_path


# 音楽の進行状況を発信するためのROSノード
def audio_player(file_path):
    if not os.path.exists(file_path):
        print(f"Error: File '{file_path}' not found.")
        return

    # VLC メディアプレーヤーのインスタンス作成
    player = vlc.MediaPlayer(file_path)

    # 音楽の再生開始
    player.play()
    print("Music playing started.")

    # # 音楽の全長（秒）を取得
    # duration = player.get_length() / 1000  # 音楽の全長（秒）
    # print(f"Duration: {duration:.2f} seconds")

    # ROSノードの初期化
    rospy.init_node('audio_player', anonymous=True)
    pub = rospy.Publisher('/audio/current_position', Float64, queue_size=1)

    # 一時停止・再開のフラグ
    paused = False
    running = True  # プログラム実行中フラグ

    # 音楽の進行状況を発信するスレッド
    def log_current_position():
        rate = rospy.Rate(30)

        # last_posとcounterの初期化
        if not hasattr(log_current_position, "last_pos"): log_current_position.last_pos = 0
        if not hasattr(log_current_position, "counter"):  log_current_position.counter = 0

        while running and not rospy.is_shutdown():
            if player.is_playing() and not paused:  # 再生中の場合のみ進行状況を更新
                current_pos_raw = player.get_time() / 1000.0  # ミリ秒を秒に変換

                # current_posが前回と同じ値なら適当に補間する
                if log_current_position.last_pos == current_pos_raw:
                    log_current_position.counter += 1
                else: log_current_position.counter = 0
                log_current_position.last_pos = current_pos_raw
                current_pos = current_pos_raw + log_current_position.counter/30.0 # 30 Hz by rospy.Rate(30)

                rospy.loginfo(f"Current position: {current_pos:.5f} seconds counter {log_current_position.counter}")
                pub.publish(current_pos)  # 現在の進行位置をトピックで発信
            rate.sleep()

    # 音楽再生の位置を1秒ごとに表示するスレッドを開始
    log_thread = threading.Thread(target=log_current_position, daemon=True)
    log_thread.start()

    # キーボードイベントを処理する関数
    def on_press(key):
        nonlocal paused, running
        try:
            if hasattr(key, 'char') and key.char is not None:
                key_pressed = key.char.lower()

                if key_pressed == '2':
                    # 一時停止/再開
                    if paused:
                        player.play()
                        print("Resumed")
                    else:
                        player.pause()
                        print("Paused")
                    paused = not paused

                elif key_pressed == '3':
                    # 10秒進む
                    current_pos = player.get_time() / 1000
                    new_pos = current_pos + 10
                    player.set_time(int(new_pos * 1000))  # ミリ秒単位でセット
                    print(f"Forward 10 seconds. New position: {new_pos:.2f} seconds")

                elif key_pressed == '1':
                    # 10秒戻る
                    current_pos = player.get_time() / 1000
                    new_pos = current_pos - 10
                    if new_pos < 0:
                        new_pos = 0
                    player.set_time(int(new_pos * 1000))  # ミリ秒単位でセット
                    print(f"Rewind 10 seconds. New position: {new_pos:.2f} seconds")

            elif key == keyboard.Key.esc:
                # 停止してプログラムを終了
                print("Stopping and exiting program...")
                player.stop()
                running = False  # スレッド停止
                rospy.signal_shutdown("ESC key pressed")  # ROSノードを終了
                time.sleep(0.1)  # 少し待機してから
                sys.exit(0)  # プログラム完全終了

        except AttributeError:
            pass

    # キー入力リスナーの開始
    with keyboard.Listener(on_press=on_press) as listener:
        listener.join()

if __name__ == "__main__":
    # # file_path = "/home/m-aoki/Downloads/もうええわ.m4a"
    # file_path = "/home/m-aoki/Downloads/もうええわ_detected_tempo_based_using_drums.mp3"
    # # file_path = "/home/m-aoki/Downloads/もうええわ_drums_detected_tempo_based_using_drums.mp3"
    # # file_path = "/home/m-aoki/Downloads/RetroFuture-Clean.mp3"
    audio_player(file_path)
