# jedy_dance
![jedy](jedy_side.png)

自主プロ作品

卓上双腕移動台車ロボットjedyに、指定した曲に合わせてダンスをさせるためのシステムです。

アルゴリズムの概略：

1. 楽曲ファイルを読み込む（このとき歌詞の言語を日本語／英語から選択する）
2. 【音楽解析】ビートの時刻位置推定、選択した言語での歌詞抽出（音声認識）と、その歌詞によるネガポジ/曲調（滑らかさ）の定量化を行う
3. 【振付生成】2に基づいて、楽曲に合ったダンスの振り付けを生成
4. 【リアルタイム制御】楽曲の再生状況に応じた関節角度指令をロボットに送る（キーボード入力で、2: 再生/一時停止、1: 10秒戻し、3: 10秒送りの操作が可能）

## 環境構築

動作確認済みの環境: **Ubuntu 20.04 LTS + ROS Noetic**。以下は実際にこの構成でゼロから
セットアップして通しで動作確認した手順です。

### 1. ROS Noeticのインストール

```bash
sudo apt update
sudo apt install -y curl gnupg2 lsb-release
sudo sh -c 'echo "deb http://packages.ros.org/ros/ubuntu $(lsb_release -sc) main" > /etc/apt/sources.list.d/ros-latest.list'
curl -s https://raw.githubusercontent.com/ros/rosdistro/master/ros.asc | sudo apt-key add -
sudo apt update
sudo apt install -y ros-noetic-desktop-full python3-rosdep python3-catkin-tools
sudo rosdep init
rosdep update --include-eol-distros   # Noetic は EOL 扱いなのでこのフラグが必須
echo "source /opt/ros/noetic/setup.bash" >> ~/.bashrc
source /opt/ros/noetic/setup.bash
```

### 2. システムパッケージ

```bash
sudo apt install -y python3-tk python3-pip ffmpeg vlc libvlc-dev git gnome-terminal \
  ros-noetic-ros-control ros-noetic-ros-controllers ros-noetic-gazebo-ros-control \
  ros-noetic-ridgeback-control
```

### 3. リポジトリの取得と`ros`ワークスペースの展開

このリポジトリは、ダンス制御一式（`Dancing_Jedy`本体）に加えて、必要なROSワークスペースの
ソース一式（`build`/`devel`/`logs`を除く）を`ros/`フォルダに同梱しています。**同梱の`ros/`は
jedy用にカスタマイズ済みで、これが唯一の正となるバージョンです**（上流リポジトリからの再取得や
更新は不要かつ非推奨。詳細は手順4）。

```bash
cd ~
git clone https://github.com/pontarou5/Dancing_Jedy.git Dancing_Jedy-clone
mkdir -p ~/ros
mv ~/Dancing_Jedy-clone/ros/enshu_ws ~/ros/enshu_ws
rm -rf ~/Dancing_Jedy-clone/ros
mv ~/Dancing_Jedy-clone ~/Dancing_Jedy
```

`analyzed_music_data/data_*.py` の `file_path` はリポジトリ直下からの相対パス
（例: `original_musics/ダンスホール.mp3`）で保存されており、`music_publish.py` が
スクリプトの場所を基準に解決するため、環境ごとのパス書き換えは不要です。

### 4. ROSワークスペースのビルド

**同梱の `ros/enshu_ws/src` をそのまま使ってビルドします。** `src` は jedy 用にカスタマイズ
済みで、`vcsinstall.noetic.yaml` を使った `vcs import` / `vcs pull` による再取得・更新は
**行わないでください**（カスタマイズが上書きされます）。`vcstool` も不要です。

ワークスペースは `catkin_tools`（`catkin build`）でビルドします。`jedy_bringup` を指定すると
その依存パッケージだけがビルドされるため、同梱ワークスペース全体（60超のパッケージ）を
ビルドする必要はありません。

```bash
source /opt/ros/noetic/setup.bash
cd ~/ros/enshu_ws

# 【重要】rosdistro が Noetic を EOL 扱いにしたため、--include-eol-distros が必須。
# これを付けないと "Skip end-of-life distro noetic" となり、pr2eus / jskeus などの
# 依存キー（apt パッケージ）が一切解決できません。
rosdep update --include-eol-distros
rosdep install --from-paths src --ignore-src -y -r --rosdistro noetic

catkin build jedy_bringup
echo "source ~/ros/enshu_ws/devel/setup.bash" >> ~/.bashrc
source ~/ros/enshu_ws/devel/setup.bash
rospack find jedy_bringup   # 見つかればOK
```

> `rosdep install` は `src` 内の全パッケージの依存を調べるため、`jedy_bringup` に関係しない
> パッケージ（`turtlebot_follower` など）で「rosdep 定義が見つからない」旨のエラーが出ることが
> あります。`-r`（エラーが出ても続行）を付けているので無視して問題ありません。`catkin build
> jedy_bringup` は `jedy_bringup` の依存ツリーだけをビルドするため影響しません。

#### `kxr_controller` / `kxreus` の venv ビルドが `pycollada` で失敗する場合

`catkin_virtualenv` が `pip-compile` する際、以下のエラーで止まることがあります。

```
Could not find a version that matches pycollada<=0.9,==0.7.1,>=0.8
There are incompatible versions in the resolved dependencies:
  pycollada==0.7.1  ...
  pycollada<=0.9,>=0.8 (from scikit-robot==0.3.19->...)
```

`src/rcb4/ros/kxr_controller/requirements.in` と `src/rcb4/ros/kxreus/requirements.in` が
`pycollada==0.7.1` を固定していますが、現在の PyPI では `scikit-robot`（`no_mesh_load_mode`
等を使うため必須）のどのバージョンも `pycollada>=0.8` を要求し、両立しません。両ファイルを
次のように変更してください（同梱 src では対応済み）。

```diff
- scikit-robot>=0.0.45
+ scikit-robot==0.3.19
- pycollada==0.7.1
+ pycollada==0.8
```

### 5. Pythonライブラリのインストール

依存関係の全体は`requirements.txt`にまとめていますが、**`pip install -r requirements.txt`を
一括実行すると、pipの依存解決がtensorflow(spleeter経由)とtorch/pyOpenSSL/librosaの
`typing-extensions`要求で衝突し失敗することを確認しています**。そのため、実際に動作確認できた
以下の順序でグループごとにインストールしてください。

```bash
cd ~/Dancing_Jedy
python3 -m pip install --user --upgrade pip

# 1. ビート検出・音声処理
python3 -m pip install --user pydub SpeechRecognition librosa

# 2. PyTorch (CPU版)
python3 -m pip install --user torch torchvision torchaudio --index-url https://download.pytorch.org/whl/cpu

# 3. 歌詞の明るさ(brightness)分析用
python3 -m pip install --user transformers fugashi unidic_lite sentencepiece ipadic

# 4. 音源分離 (spleeter, TensorFlowが付随してインストールされる)
python3 -m pip install --user spleeter

# 5. システムの古いh5py/pyOpenSSLがspleeterの依存(numpy/cryptography)と衝突するため上書き
#    (numpy.typeDict / X509_V_FLAG_NOTIFY_POLICY 関連のエラーが出る場合はこれが原因)
python3 -m pip install --user --upgrade h5py
python3 -m pip install --user --upgrade pyopenssl

# 6. 音楽再生・GUI操作用
python3 -m pip install --user python-vlc pynput
```

`music_analysis.py`/`dance_generation.py`（新しい曲の追加）を使わず、既存曲でダンスさせる
だけなら、手順5は不要です（`music_publish.py`用のpython-vlc・pynputだけあれば足ります）。

### 6. 動作確認

```bash
cd ~/Dancing_Jedy
python3 gui_dancing_jedy_sim.py   # シミュレーション(Gazebo)版
# python3 gui_dancing_jedy_real.py  # 実機版
```

GUI で曲を選ぶと、別ターミナルで Gazebo と roseus のダンス制御、および `music_publish.py`
（音楽再生）が起動します。「新しい曲のダンスを生成」では mp3 を選んだあとに歌詞の言語
（日本語／英語）を選ぶ画面が出て、その言語で `music_analysis.py --lang` の歌詞抽出が
行われます（CLI で直接実行する場合の既定は `ja`）。distrobox で動かす場合は、上記の `.bashrc` 追記と
`gnome-terminal` ラッパーを入れた状態で `distrobox enter jedy` した対話シェルから起動して
ください（GPU 無しのホストでは Gazebo が software rendering になり動作が重くなります）。

## Ubuntu 20.04以外の環境で動かす方法

ROS Noeticは公式にはUbuntu 20.04 (Focal) 専用です。それ以外のOS・ディストリビューションで
動かす場合は、以下のいずれかの方法を取ってください。実際に **Ubuntu 24.04 のホスト上で
distrobox（方法A）を使って通しでセットアップした際の注意点** を各所に追記しています。

### 方法A: distrobox（Ubuntu 20.04 コンテナ / 推奨）

`distrobox` は `podman`/`docker` の上に「ホームディレクトリ・X11・音声をホストと共有した」
コンテナを作るツールです。手動での `docker run` オプション（X11ソケット・`DISPLAY`・`--net`）
指定が不要で、GazeboのGUIやVLC再生もそのまま動きます。ホスト（Ubuntu 22.04/24.04 等）に
`podman` と `distrobox` を入れておきます。

```bash
# ホスト側
sudo apt install -y podman distrobox

# Ubuntu 20.04 + ROS Noetic のコンテナを作成（ROS入りイメージなので「手順1」は不要）
# --home でコンテナ専用ホームを与え、ホストの ~/.local や dotfile と混ざらないようにする
mkdir -p ~/.distrobox-homes/jedy
distrobox create --name jedy \
  --image docker.io/osrf/ros:noetic-desktop-full \
  --home ~/.distrobox-homes/jedy

distrobox enter jedy
```

以降はコンテナ内で「環境構築」の **手順2〜6をそのまま** 実行します。ただし distrobox 特有の
ハマりどころがいくつかあるので、まずコンテナ専用の `~/.bashrc`（`~/.distrobox-homes/jedy/.bashrc`。
ホスト側 `~/.bashrc` とは別ファイル）の末尾に次をまとめて追記します。

```bash
# --- Dancing_Jedy / distrobox setup ---
if [ -n "$CONTAINER_ID" ]; then
    # (a) ホスト pyenv の PATH 混入を除去（← コンテナ python3 が /usr/bin/python3 になる）
    export PATH="$(printf '%s' "$PATH" | tr ':' '\n' | grep -v '/\.pyenv/' | grep -v '/\.pyenv$' | paste -sd ':' -)"
    unset PYENV_ROOT PYENV_SHELL PYENV_VERSION
    hash -r
    # (b) catkin_tools はフルパスの SHELL を要求する
    export SHELL=/bin/bash
    # (c) ROS 環境を自動 source（GUI から起動する子プロセスにも引き継がれる）
    [ -f /opt/ros/noetic/setup.bash ] && source /opt/ros/noetic/setup.bash
    [ -f "$HOME/ros/enshu_ws/devel/setup.bash" ] && source "$HOME/ros/enshu_ws/devel/setup.bash"
    # (d) python-xlib / pynput をホストの X サーバーに接続させる
    if [ -n "$DISPLAY" ] && command -v xhost >/dev/null 2>&1; then
        xhost +SI:localuser:"$(id -un)" >/dev/null 2>&1
    fi
fi
```

さらに **(e) `gnome-terminal` ラッパー** をコンテナ内に置きます（下記）。追記・設置が済んだら
`exit` → `distrobox enter jedy` で入り直し、`python3 --version` が `Python 3.8.x`
（＝`/usr/bin/python3`）になっていることを確認してから手順2へ進みます。

- **(a) pyenv 混入**：これが無いと `python3` がホストの Python（新しい glibc 向けビルド）を指し、
  `GLIBC_2.34 not found` で `pip` が全滅します。distrobox がホストのログインシェル環境
  （`PYENV_ROOT`・`PATH` の pyenv shim）をそのまま引き継ぐのが原因です。
- **(b) `SHELL`**：フルパスでない `SHELL`（`bash` 等）を継承すると `catkin build` が
  `Cannot determine shell executable` で落ちます。
- **(c) ROS の source**：GUI（`python3 gui_dancing_jedy_sim.py`）から起動される roslaunch /
  roseus の子プロセスは、GUI プロセスの環境を継承します。対話シェルで ROS が source されて
  いれば子にも渡ります。
- **(d) `pynput` の X 接続**：`music_publish.py` が使う `pynput`（python-xlib 経由）は、
  コンテナのホスト名がホストと異なるため MIT-MAGIC-COOKIE が一致せず
  `failed to acquire X connection … Authorization required` になります（tkinter/libX11 は
  通るのに pynput だけ落ちる）。`xhost +SI:localuser:$(id -un)` で uid ベースのアクセスを
  許可すれば解決します。
- **(e) `gnome-terminal`**：GUI は `gnome-terminal -- bash -c "roslaunch …"` で別端末を開きますが、
  `gnome-terminal` はホスト常駐の `gnome-terminal-server` に処理を委譲するため、**新しい端末が
  コンテナではなくホストで開き** `roslaunch: command not found` になります。コンテナ内に
  `--disable-factory` を強制するラッパーを置いて回避します。

  ```bash
  sudo tee /usr/local/bin/gnome-terminal >/dev/null <<'EOF'
  #!/bin/sh
  exec /usr/bin/gnome-terminal --disable-factory "$@"
  EOF
  sudo chmod +x /usr/local/bin/gnome-terminal
  ```

> **GUI の停止ボタンに注意**：`gui_dancing_jedy_sim.py` の停止処理は `pkill -9 -f ros` を実行し、
> コマンドラインに `ros` を含むプロセスを巻き込んで殺すため、distrobox/podman 側のプロセスが
> 落ちて `unable to find user … in passwd file` になることがあります。その場合は
> `distrobox stop jedy` してから `distrobox enter jedy` で入り直せば復旧します。

コンテナは `distrobox enter jedy` でいつでも再入室できます。不要になったら
`distrobox rm jedy` （＋ `rm -rf ~/.distrobox-homes/jedy`）で削除できます。

### 方法B: Docker

**Ubuntu 24.04 ホスト（X11 は Xwayland、音声は PipeWire）で新曲追加まで含めて通しで動作確認済み。**
distrobox（方法A）と違い、ホストの D-Bus セッションバスもログインシェル環境も継承しないため、
pyenv 混入も `gnome-terminal` のホスト委譲も起きず、回避策が少なくて済みます。以下は
`osrf/ros:noetic-desktop-full`（Ubuntu 20.04 + ROS Noetic 同梱）を root ユーザーで使う手順です。
「環境構築」の手順1（ROS 導入）は不要、手順2〜6 を Docker 向けに調整して実行します。

#### B-1. コンテナ起動（ホスト側）

```bash
xhost +local:                 # ローカルX接続を許可（pynput/tkinter/Gazebo すべてこれで通る）

docker run -d --name jedy_b --net=host \
  -e DISPLAY="$DISPLAY" \
  -e PULSE_SERVER="unix:$XDG_RUNTIME_DIR/pulse/native" \
  -e PULSE_COOKIE=/root/.config/pulse/cookie \
  -v /tmp/.X11-unix:/tmp/.X11-unix \
  -v "$XDG_RUNTIME_DIR/pulse/native:$XDG_RUNTIME_DIR/pulse/native" \
  -v "$HOME/.config/pulse/cookie:/root/.config/pulse/cookie:ro" \
  -v "$HOME/Downloads:/host/Downloads" \
  -v "$HOME/Music:/host/Music:ro" \
  osrf/ros:noetic-desktop-full sleep infinity

docker exec -it jedy_b bash    # 以降この中で作業
```

マウントの意味：

| マウント / 環境変数 | 目的 |
|---|---|
| `DISPLAY` ＋ `/tmp/.X11-unix` | GUI・Gazebo・rviz の表示 |
| `PULSE_SERVER` ＋ `pulse/native` ＋ `pulse/cookie` | `music_publish.py` の音楽再生。**無いと Gazebo は映るが曲が鳴らない** |
| `$HOME/Downloads:/host/Downloads` | 「新しい曲のダンスを生成」で選ぶ mp3 をコンテナから見えるようにする |

#### B-2. システムパッケージ（手順2 相当・コンテナ内）

`osrf/ros` イメージには `catkin build`（catkin_tools）が入っていないので `python3-catkin-tools`
を追加します。素のイメージに `gnome-terminal` を普通に入れると Recommends 連鎖で GNOME
デスクトップ一式（約570パッケージ / 160MB）が来るので `--no-install-recommends` を付けます
（`xterm` でも可）。

```bash
apt-get update
apt-get install -y --no-install-recommends \
  python3-tk python3-pip python3-catkin-tools ffmpeg vlc libvlc-dev git \
  gnome-terminal dconf-gsettings-backend gsettings-desktop-schemas \
  pulseaudio-utils libpulse0 \
  ros-noetic-ros-control ros-noetic-ros-controllers ros-noetic-gazebo-ros-control \
  ros-noetic-ridgeback-control
```

> `--no-install-recommends` 抜きの通し確認はできていますが（GNOME 一式込みで約570パッケージ）、
> `--no-install-recommends` 版で `gnome-terminal` が `Failed to create terminal` 等で起動
> しない場合は、`--no-install-recommends` を外すか `dbus-x11` を追加してください。

#### B-3. リポジトリ取得・ワークスペース展開・`requirements.in` 修正（手順3 相当）

```bash
cd /root
git clone https://github.com/pontarou5/Dancing_Jedy.git Dancing_Jedy-clone
mkdir -p /root/ros
mv /root/Dancing_Jedy-clone/ros/enshu_ws /root/ros/enshu_ws
rm -rf /root/Dancing_Jedy-clone/ros
mv /root/Dancing_Jedy-clone /root/Dancing_Jedy

# kxr_controller / kxreus の requirements.in の pycollada 固定を修正（手順4の小節と同じ理由）
for f in /root/ros/enshu_ws/src/rcb4/ros/kxr_controller/requirements.in \
         /root/ros/enshu_ws/src/rcb4/ros/kxreus/requirements.in; do
  sed -i 's/^scikit-robot.*/scikit-robot==0.3.19/; s/^pycollada==0.7.1$/pycollada==0.8/' "$f"
done
```

#### B-4. ビルド（手順4 相当）

```bash
source /opt/ros/noetic/setup.bash
rosdep update --include-eol-distros         # root だと警告が出るが動く
cd /root/ros/enshu_ws
rosdep install --from-paths src --ignore-src -y -r --rosdistro noetic || true
catkin build jedy_bringup
source /root/ros/enshu_ws/devel/setup.bash
rospack find jedy_bringup
```

#### B-5. Python ライブラリ（手順5 相当）

「環境構築」の手順5 のコマンドをそのまま実行します。root 実行なので `--user` は `/root/.local`
に入ります（`pandas`/`launchpadlib` 等の互換警告は無害、import は通ります）。

#### B-6. 起動（手順6 相当）

毎回の環境設定を `/root/.bashrc` に入れておくと `docker exec -it jedy_b bash` するだけで済みます。

```bash
cat >> /root/.bashrc <<'EOF'
source /opt/ros/noetic/setup.bash
[ -f /root/ros/enshu_ws/devel/setup.bash ] && source /root/ros/enshu_ws/devel/setup.bash
export PATH=$HOME/.local/bin:$PATH
EOF

cd /root/Dancing_Jedy && python3 gui_dancing_jedy_sim.py
```

#### Docker 固有の補足

- **`gnome-terminal` はラッパー不要**：コンテナ内に `gnome-terminal-server` が居ないので標準の
  `gnome-terminal` がそのままコンテナ内でシェルを起動します（方法A の `--disable-factory`
  ラッパー不要）。`Couldn't connect to accessibility bus` 等の警告は無害。
- **音声確認**：`pactl info`（`Server Name: PulseAudio (on PipeWire ...)` と `Default Sink`
  が出れば接続 OK）。任意の wav を `paplay <file>.wav` で鳴らして確認。
- **新曲のファイル選択**：GUI のダイアログは `_default_music_dir()`（`gui_dancing_jedy_*.py`）で
  `/host/Music` → `/host/Downloads` → `~/Downloads` → `~/Music` → `~` の順に見て、
  **mp3 が実際に入っている最初のディレクトリ** を初期表示します。ホストの mp3 置き場を
  `-v ...:/host/Downloads` でマウントしておけばそのまま選べます。
- **GPU**：音声認識 / 学習を速くしたい場合は `--gpus all` ＋ CUDA 版 PyTorch イメージ
  （本プロジェクトは CPU 版 PyTorch で確認済み）。
- **コンテナ管理**：再入室 `docker exec -it jedy_b bash`、停止/再開 `docker stop|start jedy_b`
  （writable レイヤは保持）、破棄 `docker rm -f jedy_b`。ビルド済み状態を残すなら
  `docker commit jedy_b jedy_b:built` でイメージ化できます。

macOS は Docker Desktop + [XQuartz](https://www.xquartz.org/)、Windows は WSL2 + Docker
Desktop（WSLg が X11 を自動対応）で同様の手順が使えます（音声経路は各環境で別途設定）。
