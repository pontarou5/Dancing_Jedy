#!/bin/bash

# 曲名リスト（mp3を除いた名前）
songs=(
    "Faded"
    "your-loss-looks-good-on-me"
    "first-light"
    "limited-edition-by-tyler-havlice"
    "ltcuz-my-heart-is-beatinggt-by-2sonmoa"
    "Make_Me_Move"
)

# wheel_move_dance_.l の内容
read -r -d '' WHEEL_MOVE_CONTENT <<'EOF'
#!/usr/bin/env roseus

(setq beat-times '() )

;; ROSパッケージをロード
(ros::load-ros-manifest "std_msgs")

;; ノードの初期化
(ros::roseus "audio_subscriber")

;; 最新のトピックデータを格納するための変数を定義
(defparameter *current-position* 0)

;; std_msgs/Float64メッセージ型を利用してトピックをサブスクライブ
(ros::subscribe "/audio/current_position" std_msgs::float64
  #'(lambda (msg)
      (setf *current-position* (send msg :data))))

;;実機とつなぐかどうか
(setq *use-robot* t)
; (setq *use-robot* nil)

;; 実機の初期設定
(when *use-robot*
  (load "package://jedy_bringup/euslisp/jedy-interface.l")
  (jedy-init)

  (send *ri* :send-stretch
    :names '("rarm_joint0" "rarm_joint1" "rarm_joint2" "rarm_joint3"
             "rarm_joint4" "rarm_joint5" "rarm_joint6" "rarm_gripper_joint"
             "larm_joint0" "larm_joint1" "larm_joint2" "larm_joint3"
             "larm_joint4" "larm_joint5" "larm_joint6" "larm_gripper_joint"
             "head_joint0" "head_joint1" "front_right_wheel_joint"
             "front_left_wheel_joint" "rear_right_wheel_joint"
             "rear_left_wheel_joint")
    :value '(64 64 64 64 127 127 127 127 127 127 127 127 127 127 127 127))

  (send (send *ri* :read-stretch) :slots)

  (send *ri* :servo-on)
)

;; 以下、ビートとwheel-moveの処理（省略せずに挿入してください）
;; ...（長文なので省略可能ですが、必要なら全文をここに置く）
EOF

# ファイル作成ループ
for song in "${songs[@]}"; do
    # jedy_dance_subscribe_*.l を空ファイル作成
    touch "jedy_dance_subscribe_${song}.l"

    # wheel_move_dance_*.l を内容付きで作成
    echo "$WHEEL_MOVE_CONTENT" > "wheel_move_dance_${song}.l"
done

echo "Files created successfully."
