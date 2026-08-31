import tkinter as tk
from tkinter import ttk

global music_name
music_name = "ダンスホール"

def on_select(event):
    selected_option = combo.get()  # プルダウンメニューで選択された項目を取得
    print(f"選択された曲: {selected_option}")
    music_name = selected_option

# メインウィンドウの作成
root = tk.Tk()
root.title("プルダウンメニューの例")

# プルダウンメニューの選択肢をリストにする
options = ["カメレオン", "ダンスホール", "愛を込めて花束を"]

# ttk.Comboboxを使用してプルダウンメニューを作成
combo = ttk.Combobox(root, values=options, state="readonly")
combo.set("ダンスホール")  # デフォルトで「ダンスホール」を選択
combo.bind("<<ComboboxSelected>>", on_select)  # 選択が変わったときの処理
combo.pack(pady=20)

# メインループを開始
root.mainloop()
