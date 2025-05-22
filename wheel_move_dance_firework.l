#!/usr/bin/env roseus

yet editted !!!
(setq beat-times '(8.789 9.253 9.729 10.217 10.704 11.192 11.668 12.156 12.632 13.131 13.607 14.095 14.594 15.07 15.534 16.033 16.521 16.997 17.473 17.972 18.448 18.936 19.412 19.9 20.376 20.863 21.339 21.827 22.314 22.79 23.278 23.789 24.265 24.752 25.217 25.704 26.192 26.691 27.144 27.643 28.131 28.607 29.083 29.582 30.07 30.546 31.022 31.521 32.009 32.496 32.949 33.448 33.924 34.412 34.888 35.387 35.875 36.362 36.827 37.326 37.802 38.301 38.766 39.277 39.753 40.24 40.728 41.215 41.703 42.179 42.667 43.143 43.63 44.106 44.594 45.082 45.558 46.045 46.533 47.009 47.496 47.984 48.472 48.948 49.435 49.923 50.411 50.887 51.363 51.85 52.338 52.825 53.301 53.789 54.265 54.753 55.229 55.716 56.204 56.692 57.179 57.655 58.143 58.619 59.095 59.582 60.058 60.546 61.034 61.521 62.009 62.497 62.973 63.46 63.948 64.435 64.923 65.399 65.887 66.374 66.85 67.338 67.814 68.301 68.789 69.265 69.741 70.229 70.716 71.204 71.668 72.156 72.644 73.108 73.596 74.095 74.582 75.059 75.535 76.034 76.498 76.997 77.473 77.961 78.437 78.925 79.412 79.888 80.376 80.863 81.34 81.839 82.303 82.791 83.29 83.766 84.254 84.741 85.217 85.705 86.192 86.68 87.144 87.644 88.131 88.619 89.083 89.571 90.07 90.546 91.022 91.521 91.986 92.497 92.949 93.46 93.948 94.424 94.888 95.388 95.875 96.351 96.827 97.326 97.814 98.29 98.754 99.254 99.741 100.241 100.705 101.204 101.68 102.168 102.632 103.12 103.596 104.095 104.559 105.047 105.535 106.034 106.498 106.951 107.474 107.961 108.437 108.936 109.412 109.9 110.376 110.864 111.351 111.827 112.303 112.791 113.279 113.778 114.242 114.73 115.217 115.717 116.193 116.692 117.168 117.656 118.143 118.631 119.107 119.594 120.082 120.558 121.034 121.522 121.998 122.485 122.973 123.46 123.948 124.424 124.912 125.399 125.887 126.375 126.862 127.338 127.826 128.313 128.789 129.277 129.753 130.241 130.728 131.204 131.692 132.18 132.656 133.132 133.608 134.095 134.583 135.059 135.535 136.034 136.51 136.998 137.474 137.961 138.449 138.937 139.413 139.9 140.376 140.864 141.34 141.827 142.303 142.791 143.279 143.766 144.242 144.73 145.206 145.694 146.181 146.68 147.156 147.656 148.132 148.619 149.084 149.571 150.059 150.535 151.023 151.51 151.986 152.485 152.961 153.449 153.925 154.424 154.9 155.388 155.852 156.34 156.828 157.304 157.791 158.279 158.766 159.254 159.73 160.218 160.694 161.193 161.681 162.168 162.656 163.143 163.608 164.084 164.56 165.059 165.535 166.023 166.51 166.998 167.474 167.962 168.438 168.937 169.413 169.889 170.365 170.852 171.34 171.828 172.304 172.791 173.279 173.778 174.243 174.73 175.206 175.705 176.17 176.657 177.157 177.644 178.132 178.631 179.119 179.595 180.082 180.57 181.058 181.545 182.021 182.497 182.985 183.461 183.948 184.436 184.924 185.4 185.887 186.363 186.839 187.339 187.826 188.291 188.801 189.277 189.753 190.241 190.729 191.205 191.669 192.18 192.656 193.144 193.62 194.107 194.583 195.071 195.535 196.023 196.51 196.998 197.474 197.962 198.449 198.937 199.413 199.901 200.377 200.864 201.34 201.839 202.315 202.803 203.279 203.767 204.254 204.742 205.218 205.706 206.182 206.669 207.145 207.633 208.12 208.608 209.084 209.572 210.059 210.547 211.023 211.511 211.998 212.486 212.962 213.449 213.937 214.413 214.889 215.377 215.864 216.352 216.828 217.327 217.803 218.279 218.767 219.254 219.73 220.23 220.694 221.182 221.669 222.157 222.633 223.121 223.597 224.084))



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



;;実機の初期設定
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



;; ビートタイミングとポーズを定義するリスト
; (setq beat-times '(24.207 24.938 25.670 26.401 27.133 27.864 28.595 29.327 30.058 30.790 31.509 32.253 32.972 33.704 34.435 35.167 35.886 36.618 37.349 38.104 38.824 39.555 40.287 41.030 41.761 42.493 43.212 43.955 44.687 45.418 46.150 46.869 47.624 48.367 49.087 49.818 50.550 51.270 52.013 52.744 53.476 54.207 54.938 55.681 56.401 57.121 57.841 58.584 59.292)
)

;; wheel-move-beat-timesを初期化
(setq wheel-move-beat-times '())

;;beat-pose-dictionaryをalternating-poseをもとに作成
(setq *counter-beat* 0)
(dolist (beat-time beat-times)
    (setf *counter-beat* (+ 1 *counter-beat*))
    (if (= 0 (mod *counter-beat* 4))
        (push beat-time wheel-move-beat-times))
)
(setq wheel-move-beat-times (sort wheel-move-beat-times `(lambda (a b) (< a b))))
(ros::ros-info "~A" wheel-move-beat-times)


;; ビート時刻とwheel-moveのペアを格納する辞書型リスト
(setq beat-wheel-move-dictionary '())

;; 規則的に4種類のwheel-moveを当てはめる関数
(defun alternating-wheel-move (counter)
  "Return an alternating pose based on the current index (counter mod 4)."
  (let (
        (stand-still '(0 0 0))
        (move-foward '(1 0 0))
        (move-backward '(-1 0 0))
        (rotate-right '(0 0 2))
        (rotate-left '(0 0 -2))
        (move-right '(0 2 0))
        (move-left '(0 -2 0))
       )
    (case (mod counter 7)
      (0 move-foward)
      (1 stand-still)
      (2 rotate-right)
      (3 move-right)
      (6 move-left)
      (5 rotate-left)
      (4 move-backward)
      )))

;beat-wheel-move-dictionaryをalternating-poseをもとに作成
(setq *counter-pose* 0)
(dolist (beat-time wheel-move-beat-times)
    (setf *counter-pose* (+ 1 *counter-pose*))
  (let ((selected-wheel-move (alternating-wheel-move *counter-pose*)))
    (push (cons beat-time selected-wheel-move) beat-wheel-move-dictionary)))

(setq beat-wheel-move-dictionary (sort beat-wheel-move-dictionary `(lambda (a b) (< (car a) (car b)))))
(ros::ros-info "~A" beat-wheel-move-dictionary)

(defun set-current-index (current-position beat-times)
  ; (ros::ros-info "run function : set-current-index")
  (let ((current-index 0))
    (dolist (beat-time beat-times)
      (unless (numberp beat-time)
        (ros::ros-info "beat-time is ~A so it is invalid" beat-time)
        (return-from set-current-index nil))
      (when (> beat-time current-position)
        ; (ros::ros-info "current-index: ~A | current-beat: ~A" current-index beat-time)
        ; ;; 戻り値の型をログに明示
        ; (ros::ros-info "Returning: ~A" (list current-index beat-time))
        (return-from set-current-index (list current-index beat-time))
      )
      (incf current-index))
    nil))

(defun get-next-info (current-position beat-pose-dictionary current-index current-beat)
  "Returns the information for the next beat if the current position is close to the current beat."
  (let* ((current-beat-and-pose (nth current-index beat-pose-dictionary)) ;; 現在のビート情報
         (tolerance 0.05)) ;; 許容誤差（例: 100ms）
    
    ; ; 変数の状態を出力
    ; (format t "DEBUG: current-position=~A, current-beat=~A, current-index=~A~%"
    ;         current-position current-beat current-index)
    
    ;; 近いビートがあるかどうかを確認
    (if (or (<= (abs (- current-position current-beat)) tolerance) ;; 最初のビートも許容
            (= current-index 0))                                 ;; 最初のビートを強制的に処理
        (progn
          (format t "DEBUG: Close enough or first beat - checking next beat~%")
          (let ((next-index (+ 1 current-index))) ;; 次のインデックスを計算
            ;; 次のインデックスが範囲内か確認
            (if (< next-index (length beat-pose-dictionary))
                (let* ((next-beat-and-pose (nth next-index beat-pose-dictionary)) ;; 次のビート情報
                       (next-time (car next-beat-and-pose))                        ;; 次のビート時刻
                       (next-pose (cdr next-beat-and-pose)))                       ;; 次のビートのポーズ
                  ;; 結果を計算して返す
                  (format t "DEBUG: Found next beat at index ~A: next-time=~A, next-pose=~A~%"
                          next-index next-time next-pose)
                  (list (* 0.90 (- next-time current-position)) next-time next-pose next-index))
                ;; 次のインデックスが範囲外の場合のログ
                (progn
                  ; (format t "DEBUG: Next index (~A) is out of range~%" next-index)
                  (send *ri* :servo-off)
                  (return-from get-next-info nil)))))

      ;; 近いビートがない場合のログ
      ; (format t "DEBUG: No beat is close enough: current-position=~A, current-beat=~A~%"
      ;         current-position current-beat)
      (return-from get-next-info nil))))

                                         
        
;; 直後のビートのインデックスを保持
(setq current-index 0)

;; 実行部分、進行状況をインデックスで管理
(ros::rate 30)

(do-until-key

  (ros::spin-once)  ;; コールバックを処理
  (if *current-position*  ;;この条件が満たされた時のみ以下全体の処理を行う
    (progn
      ; (format t "*current-position*: ~A seconds~%" *current-position*)
      ; (ros::ros-info "got valid current-position")    
      (let* ((current-index-and-beat  (set-current-index *current-position* wheel-move-beat-times))
            (current-index  (car current-index-and-beat))
            (current-beat (first (cdr current-index-and-beat))))
        ; (ros::ros-info "current-index: ~A" current-index)

        ;;次のビートの情報を取得
        (setq next-info-list (get-next-info *current-position* beat-wheel-move-dictionary current-index current-beat))
        (if next-info-list
            (let ((time-diff (nth 0 next-info-list))
                  (next-beat (nth 1 next-info-list))
                  (pose (remove-if #'null (nth 2 next-info-list)));; なぜか含まれるnilを取り除く
                  (next-index (nth 3 next-info-list)))  ;; 新しいインデックス

              ; (ros::ros-info "*current-position*: ~A seconds" *current-position*)

              ; 次のビートの情報とポーズを送信
              (ros::ros-info "next-index: ~A | next-beat: ~A | seconds pose:~A " next-index next-beat pose)
              (ros::ros-info "time-diff: ~A" time-diff)

              (when *use-robot*
                (let ((start-time (ros::time-now)))
                  (loop
                  ;; 現在の経過時間を計算
                  (let* ((current-time (ros::time-now))
                          (elapsed-sec (- (send current-time :to-sec) (send start-time :to-sec))))

                    ;; 経過時間が制限を超えたら終了
                    (if (> elapsed-sec time-diff)
                      (return)  ;; ループを終了
                      ;; ロボットに指令を送信
                      (send *ri* :send-cmd-vel-raw (nth 0 pose) (nth 1 pose) (nth 2 pose))))

                  ;; 必要に応じてスリープを追加（例えば0.01秒）
                  (ros::sleep 0.01))))

    
                ; 終了待機状態
              (ros::ros-info "Waiting for key press...")
            )
            (progn
              (ros::ros-info "get *current-position* sucssesfully but not found beat within 0.05 s")
              (ros::ros-info "*current-position* :~A seconds" *current-position*)
            )
        )
      )
    )
    (ros::ros-info "not found *current-position*")
  )
  (ros::sleep)
)

;; プログラムの終了を防ぐためにループを維持
(ros::rate 10 (do-until-key
                 (ros::spin-once)))