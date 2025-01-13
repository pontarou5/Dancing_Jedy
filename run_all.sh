#!/bin/bash

# Lispファイル1を新しいターミナルで実行
gnome-terminal -- bash -c "roseus jedy_dance_subscribe.l; exec bash"

# Lispファイル2を新しいターミナルで実行
gnome-terminal -- bash -c "roseus wheel_move_dance.l; exec bash"

# ユーザーの入力待ち
echo "Press Enter to execute the Python script..."
read -r  # Enterキーの入力を待機

# Pythonスクリプトを新しいターミナルで実行
gnome-terminal -- bash -c "python3 music_publish_modif.py; exec bash"

echo "Press Enter to close 3 scripts..."
read -r  # Enterキーの入力を待機

pkill -f "roseus jedy_dance_subscribe.l"  
pkill -f "roseus wheel_move_dance.l"  
pkill -f "python3 music_publish_modif.py"  