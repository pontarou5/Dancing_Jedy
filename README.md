# jedy_dance
![jedy](jedy_side.png)

自主プロ作品

卓上双腕移動台車ロボット jedy に、指定した曲に合わせてダンスをさせるシステムです。

## アルゴリズムの概略

1. 楽曲ファイル(mp3)を読み込む（歌詞の言語を日本語／英語から選択）
2. **音楽解析** — ビート時刻の推定、選択言語での歌詞抽出、歌詞のネガポジ・曲調（滑らかさ）の定量化
3. **振付生成** — 2 に基づき曲に合った振り付けを生成
4. **リアルタイム制御** — 再生位置に応じた関節角度指令をロボットへ送出（キー操作: `2` 再生/一時停止、`1` 10秒戻し、`3` 10秒送り）

## 環境構築（Ubuntu 20.04 LTS + ROS Noetic）

### 1. ROS Noetic

```bash
sudo apt update
sudo apt install -y curl gnupg2 lsb-release
sudo sh -c 'echo "deb http://packages.ros.org/ros/ubuntu $(lsb_release -sc) main" > /etc/apt/sources.list.d/ros-latest.list'
curl -s https://raw.githubusercontent.com/ros/rosdistro/master/ros.asc | sudo apt-key add -
sudo apt update
sudo apt install -y ros-noetic-desktop-full python3-rosdep python3-catkin-tools
sudo rosdep init
rosdep update --include-eol-distros
echo "source /opt/ros/noetic/setup.bash" >> ~/.bashrc
source /opt/ros/noetic/setup.bash
```

> Noetic は EOL 扱いのため、`rosdep` 系コマンドには `--include-eol-distros` が必要です。

### 2. システムパッケージ

```bash
sudo apt install -y python3-tk python3-pip ffmpeg vlc libvlc-dev git gnome-terminal \
  ros-noetic-ros-control ros-noetic-ros-controllers ros-noetic-gazebo-ros-control \
  ros-noetic-ridgeback-control
```

### 3. リポジトリ取得と ROS ワークスペース展開

同梱の `ros/enshu_ws` は jedy 用に調整済みです（`vcs import` / `vcs pull` での更新は不可）。

```bash
cd ~
git clone https://github.com/pontarou5/Dancing_Jedy.git
# catkin ワークスペースは repo の外に置く（catkin build が repo を汚さないよう mv ではなく cp）
mkdir -p ~/ros
cp -r ~/Dancing_Jedy/ros/enshu_ws ~/ros/enshu_ws
```

`analyzed_music_data/data_*.py` の `file_path` は相対パス保存なので、環境ごとの書き換えは不要です。

### 4. ROS ワークスペースのビルド

```bash
source /opt/ros/noetic/setup.bash
cd ~/ros/enshu_ws
rosdep update --include-eol-distros
rosdep install --from-paths src --ignore-src -y -r --rosdistro noetic
catkin build jedy_bringup
echo "source ~/ros/enshu_ws/devel/setup.bash" >> ~/.bashrc
source ~/ros/enshu_ws/devel/setup.bash
```

`jedy_bringup` を指定すればその依存のみビルドされます（全体ビルド不要）。無関係なパッケージの rosdep エラーは `-r` で続行するため無視して構いません。

> `kxr_controller` / `kxreus` の venv ビルドが `pycollada` のバージョン競合で止まる場合は、`src/rcb4/ros/{kxr_controller,kxreus}/requirements.in` を `scikit-robot==0.3.19` / `pycollada==0.8` に変更してください（同梱 src では対応済み）。

### 5. Python ライブラリ

`pip install -r requirements.txt` の一括実行は依存解決が衝突するため、以下の順で入れてください。

```bash
cd ~/Dancing_Jedy
python3 -m pip install --user --upgrade pip
python3 -m pip install --user pydub SpeechRecognition librosa
python3 -m pip install --user torch torchvision torchaudio --index-url https://download.pytorch.org/whl/cpu
python3 -m pip install --user transformers fugashi unidic_lite sentencepiece ipadic
python3 -m pip install --user spleeter
python3 -m pip install --user --upgrade h5py pyopenssl
python3 -m pip install --user python-vlc pynput
```

既存曲でダンスさせるだけ（新曲の解析をしない）なら `python-vlc` と `pynput` だけで足ります。

### 6. 実行

```bash
cd ~/Dancing_Jedy
python3 gui_dancing_jedy_sim.py   # シミュレーション(Gazebo)版
# python3 gui_dancing_jedy_real.py # 実機版
```

GUI で曲を選ぶと、別ターミナルで Gazebo / roseus のダンス制御と `music_publish.py`（再生）が起動します。「新しい曲のダンスを生成」では mp3 選択後に歌詞の言語（日本語／英語）を選ぶ画面が出て、その言語で歌詞抽出が行われます（CLI で `music_analysis.py` を直接実行する場合の既定は `--lang ja`）。

## Ubuntu 20.04 以外の環境

ROS Noetic は Ubuntu 20.04 専用のため、コンテナで動かします。

### distrobox（推奨）

ホーム・X11・音声をホストと共有するので、GUI も音声もそのまま動きます。

```bash
# ホスト側
sudo apt install -y podman distrobox
mkdir -p ~/.distrobox-homes/jedy
distrobox create --name jedy --image docker.io/osrf/ros:noetic-desktop-full --home ~/.distrobox-homes/jedy
distrobox enter jedy
```

コンテナ専用の `~/.distrobox-homes/jedy/.bashrc` 末尾に以下を追記してから入り直します。

```bash
# --- Dancing_Jedy / distrobox setup ---
if [ -n "$CONTAINER_ID" ]; then
    # ホスト pyenv の混入を除去（コンテナの /usr/bin/python3 を使う）
    export PATH="$(printf '%s' "$PATH" | tr ':' '\n' | grep -v '/\.pyenv' | paste -sd ':' -)"
    unset PYENV_ROOT PYENV_SHELL PYENV_VERSION; hash -r
    export SHELL=/bin/bash                       # catkin build がフルパスの SHELL を要求
    [ -f /opt/ros/noetic/setup.bash ] && source /opt/ros/noetic/setup.bash
    [ -f "$HOME/ros/enshu_ws/devel/setup.bash" ] && source "$HOME/ros/enshu_ws/devel/setup.bash"
    [ -n "$DISPLAY" ] && command -v xhost >/dev/null 2>&1 && xhost +SI:localuser:"$(id -un)" >/dev/null 2>&1
fi
```

さらに、別端末がホスト側で開いてしまうのを防ぐ `gnome-terminal` ラッパーを置きます。

```bash
sudo tee /usr/local/bin/gnome-terminal >/dev/null <<'EOF'
#!/bin/sh
exec /usr/bin/gnome-terminal --disable-factory "$@"
EOF
sudo chmod +x /usr/local/bin/gnome-terminal
```

入り直したら `python3 --version` が `3.8.x`（`/usr/bin/python3`）であることを確認し、コンテナ内で「環境構築」の手順 2〜6 を実行します。

### Docker

`--net=host` で X11・音声ソケットと mp3 置き場をマウントして起動します。

```bash
xhost +local:
docker run -d --name jedy_b --net=host \
  -e DISPLAY="$DISPLAY" \
  -e PULSE_SERVER="unix:$XDG_RUNTIME_DIR/pulse/native" \
  -v /tmp/.X11-unix:/tmp/.X11-unix \
  -v "$XDG_RUNTIME_DIR/pulse/native:$XDG_RUNTIME_DIR/pulse/native" \
  -v "$HOME/Downloads:/host/Downloads" \
  osrf/ros:noetic-desktop-full sleep infinity
docker exec -it jedy_b bash
```

以降はコンテナ内で「環境構築」の手順 2〜6 を実行します（ROS 導入の手順 1 は不要、`python3-catkin-tools` の追加が必要）。ホスト環境を継承しないため pyenv 混入や `gnome-terminal` ラッパーの対応は不要です。GUI のファイルダイアログはマウント先（`/host/Downloads` 等）を自動で初期表示します。

macOS は Docker Desktop + XQuartz､
Windows は WSL2 + Docker Desktop（WSLg）で同様の手順が使えます。
