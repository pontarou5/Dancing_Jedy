#!/bin/bash

for song in APT 
# Faded firework first-light limited-edition-by-tyler-havlice \
# ltcuz-my-heart-is-beatinggt-by-2sonmoa Make_Me_Move MusMus-BGM-187 \
# permission_to_dance RetroFuture-Clean your-loss-looks-good-on-me \
# アポリア カメレオン ダンスホール もうええわ ライラック \
# 愛をこめて花束を 紅蓮華
do
    echo "Processing $song ..."
    python3 pose_generate_4beat_repeat.py "$song"
    python3 generate_wheel_move_dance_file.py "$song"
done
