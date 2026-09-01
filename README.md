# jedy_dance
![jedy](jedy_side.png)

自主プロ作品

卓上双腕移動台車ロボットjedyに、指定した曲に合わせてダンスをさせるためのシステムです。

アルゴリズムの概略：

1. 楽曲ファイルを読み込む
2. 【音楽解析】楽曲の歌詞によるネガポジ判定、ビートの時刻位置推定、曲調（滑らかさ）の定量化を行う
3. 【振付生成】2に基づいて、楽曲に合ったダンスの振り付けを生成
4. 【リアルタイム制御】楽曲の再生状況に応じた（再生/一時停止、10秒送り戻しにも対応した）関節角度指令をロボットに送る


音楽解析用に作成したコードはこちらから参照可能

//spleeterを使用した音源分離
https://colab.research.google.com/drive/18nodO3Cg6QCma0GafrH48j50DRP3K6DE?usp=sharing

//librosaを使用したビート抽出
https://colab.research.google.com/drive/1a0ExqukH8umQLp9yCtuQm-l81wBqQWzz?usp=sharing

//brightness/smoothness解析
https://colab.research.google.com/drive/1CEpwTy5hbMkic0YiylBLwTE7dLgv3BoI?usp=sharing

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

# mp3の絶対パス参照をこの環境に合わせて書き換え
find ~/Dancing_Jedy/analyzed_music_data -name "data_*.py" \
  -exec sed -i "s#/home/m-aoki/Dancing_Jedy#$HOME/Dancing_Jedy#g" {} +
```

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
（音楽再生）が起動します。distrobox で動かす場合は、上記の `.bashrc` 追記と
`gnome-terminal` ラッパーを入れた状態で `distrobox enter jedy` した対話シェルから起動して
ください（GPU 無しのホストでは Gazebo が software rendering になり動作が重くなります）。

## Ubuntu 20.04以外の環境で動かす方法

ROS Noeticは公式にはUbuntu 20.04 (Focal) 専用です。それ以外のOS・ディストリビューションで
動かす場合は、以下のいずれかの方法を取ってください。実際に **Ubuntu 24.04 のホスト上で
distrobox（方法A）を使って通しでセットアップした際の注意点** を各所に追記しています。

### 方法A: distrobox（Ubuntu 20.04 コンテナ / 最も手軽・推奨）

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

ホストOSに関係なく、コンテナ内はUbuntu 20.04として動くため最も確実です。Gazebo・GUIを
表示するにはホストのXサーバーへ接続する設定が必要です。

```bash
# ホスト側（Ubuntu 22.04/24.04など）
xhost +local:docker

docker run -it --net=host \
  -e DISPLAY=$DISPLAY \
  -v /tmp/.X11-unix:/tmp/.X11-unix \
  -v ~/Dancing_Jedy:/root/Dancing_Jedy \
  osrf/ros:noetic-desktop-full bash
```

コンテナ内で上記「環境構築」の手順2以降（ROS自体は既にイメージに含まれるので手順1は不要）を
そのまま実行してください。GPUで音声認識/機械学習を高速化したい場合は`--gpus all`を追加し、
CUDA対応のPyTorchイメージを使ってください（このプロジェクトはCPU版PyTorchで動作確認済み）。

macOSの場合はDocker Desktop + [XQuartz](https://www.xquartz.org/)、WindowsはWSL2 + Docker
Desktop（WSLgでX11転送が自動対応）で同様の手順が使えます。

### 方法C: 仮想マシン

VirtualBox/VMware等でUbuntu 20.04のVMを作成し、その中で「環境構築」の手順をそのまま実行する
方法です。Dockerより準備は簡単ですが、Gazeboの3D描画がVM内だと重くなりがちな点に注意してくだ
さい（VirtualBoxなら3Dアクセラレーションを有効化、VMwareならGPU passthroughを検討）。

### 方法D: RoboStack (conda/mamba)

Ubuntu 20.04以外のOS上に、conda環境としてROS Noeticそのものをインストールする方法です
（Linux/macOS/Windows対応、Dockerより軽量）。

```bash
conda create -n ros_env python=3.8
conda activate ros_env
conda install -c conda-forge -c robostack-staging ros-noetic-desktop
```

その後、`rosdep`/`catkin build`等のコマンド名がRoboStack環境では若干異なる場合があるので、
[RoboStack公式ドキュメント](https://robostack.github.io/)を参照しつつ、上記「環境構築」の
手順3以降（`apt`によるROS本体インストール部分を除く）を進めてください。ただし本プロジェクトは
Ubuntu 20.04 + ROS Noeticでのみ動作確認をしており、RoboStack環境での動作は未検証です。
