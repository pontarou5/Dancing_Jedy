import vlc
import time
import os
from pynput import keyboard
import threading

# 音楽の再生と制御を行う関数
def audio_player(file_path):
    if not os.path.exists(file_path):
        print(f"Error: File '{file_path}' not found.")
        return

    # VLC メディアプレーヤーのインスタンス作成
    player = vlc.MediaPlayer(file_path)

    # 音楽の再生開始
    player.play()
    print("Music playing started.")

    # 音楽の全長（秒）を取得
    duration = player.get_length() / 1000  # 音楽の全長（秒）
    print(f"Duration: {duration:.2f} seconds")

    # 一時停止・再開のフラグ
    paused = False

    # 音楽の進行状況を1秒ごとに表示するスレッド
    def log_current_position():
        while player.is_playing():  # 音楽が再生中の場合
            current_pos = player.get_time() / 1000  # ミリ秒を秒に変換
            print(f"Current position: {current_pos:.2f} seconds")
            time.sleep(1)

    # 音楽再生の位置を1秒ごとに表示するスレッドを開始
    threading.Thread(target=log_current_position, daemon=True).start()

    # キーボードイベントを処理する関数
    def on_press(key):
        nonlocal paused
        try:
            if hasattr(key, 'char') and key.char is not None:
                key_pressed = key.char.lower()

                if key_pressed == 's':
                    # 一時停止/再開
                    if paused:
                        player.play()
                        print("Resumed")
                    else:
                        player.pause()
                        print("Paused")
                    paused = not paused

                elif key_pressed == 'd':
                    # 10秒進む
                    current_pos = player.get_time() / 1000
                    new_pos = current_pos + 10
                    # if new_pos > duration:
                    #     new_pos = duration
                    player.set_time(int(new_pos * 1000))  # ミリ秒単位でセット
                    print(f"Forward 10 seconds. New position: {new_pos:.2f} seconds")
                    print(f"Current position: {player.get_time() / 1000:.2f} seconds")

                elif key_pressed == 'a':
                    # 10秒戻る
                    current_pos = player.get_time() / 1000
                    new_pos = current_pos - 10
                    if new_pos < 0:
                        new_pos = 0
                    player.set_time(int(new_pos * 1000))  # ミリ秒単位でセット
                    print(f"Rewind 10 seconds. New position: {new_pos:.2f} seconds")
                    print(f"Current position: {player.get_time() / 1000:.2f} seconds")

                elif key == keyboard.Key.esc:
                    # 停止
                    player.stop()
                    print("Stopped")
                    return False  # リスナー終了

        except AttributeError:
            pass

    # キー入力リスナーの開始
    with keyboard.Listener(on_press=on_press) as listener:
        listener.join()

if __name__ == "__main__":
    file_path = "/home/m-aoki/Downloads/RetroFuture-Clean.mp3"
    audio_player(file_path)
