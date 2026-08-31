#!/usr/bin/env roseus
(setq beat-times '(0.766 1.168 1.569 1.971 2.372 2.774 3.175 3.577 3.978 4.38 4.781 5.183 5.584 5.986 6.387 6.789 7.19 7.591 7.993 8.394 8.796 9.197 9.599 10.0 10.402 10.803 11.205 11.606 12.008 12.409 12.811 13.212 13.595 14.002 14.408 14.803 15.209 15.604 16.01 16.405 16.811 17.206 17.612 18.019 18.402 18.808 19.215 19.609 20.004 20.41 20.817 21.211 21.606 22.013 22.407 22.814 23.208 23.603 24.009 24.404 24.799 25.205 25.6 26.006 26.401 26.807 27.179 27.597 28.015 28.41 28.804 29.211 29.605 30.0 30.407 30.79 31.184 31.602 31.985 32.403 32.81 33.205 33.599 33.994 34.412 34.818 35.213 35.608 36.003 36.409 36.804 37.198 37.605 38.011 38.417 38.812 39.207 39.613 40.008 40.403 40.797 41.204 41.61 42.005 42.388 42.806 43.201 43.584 43.979 44.397 44.791 45.209 45.604 46.01 46.393 46.8 47.195 47.601 48.007 48.402 48.808 49.215 49.609 50.004 50.411 50.805 51.2 51.583 52.001 52.407 52.814 53.197 53.615 53.998 54.404 54.811 55.205 55.6 56.007 56.401 56.808 57.202 57.597 57.98 58.375 58.793 59.199 59.606 60.0 60.407 60.813 61.208 61.603 62.009 62.404 62.798 63.205 63.611 64.006 64.412 64.795 65.202 65.596 65.991 66.397 66.815 67.21 67.593 68.011 68.418 68.801 69.195 69.59 70.008 70.403 70.809 71.204 71.587 72.005 72.388 72.783 73.201 73.596 74.002 74.397 74.803 75.186 75.593 75.987 76.405 76.812 77.218 77.601 77.996 78.391 78.797 79.203 79.61 80.004 80.411 80.794 81.189 81.595 81.99 82.408 82.802 83.197 83.603 83.998 84.405 84.799 85.194 85.6 86.007 86.413 86.796 87.191 87.586 87.992 88.41 88.805 89.211 89.606 90.001 90.395 90.802 91.208 91.603 91.997 92.404 92.81 93.217 93.611 94.006 94.412 94.807 95.202 95.608 96.003 96.409 96.792 97.21 97.617 98.011 98.406 98.813 99.207 99.614 99.997 100.403 100.798 101.193 101.599 102.005 102.412 102.806 103.213 103.607 104.002 104.409 104.815 105.198 105.604 106.011 106.405 106.789 107.195 107.59 107.996 108.402 108.797 109.203 109.61 110.005 110.399 110.794 111.2 111.583 112.001 112.408 112.803 113.209 113.604 114.01 114.416 114.811 115.206 115.612 116.007 116.402 116.785 117.191 117.597 118.015 118.41 118.817 119.2 119.606 120.012 120.407 120.79 121.197 121.591 121.998 122.381 122.799 123.205 123.6 123.983 124.401 124.796 125.202 125.597 126.015 126.409 126.804 127.211 127.605 128.0 128.406 128.813 129.207 129.614 130.02 130.415 130.81 131.204 131.611 132.005 132.412 132.807 133.213 133.608 134.002 134.409 134.803 135.21 135.605 136.011 136.406 136.812 137.218 137.613 138.008 138.403 138.797 139.204 139.598 140.005 140.411 140.817 141.212 141.619 142.013 142.408 142.78 143.197 143.604 144.01 144.382 145.009 145.415 145.81 146.204 146.808 147.226 147.609 148.016 148.41 148.817 149.211 149.606 150.013 150.419 150.814 151.22 151.603 152.009 152.404 152.811 153.205 153.612 154.006 154.413 154.796 155.191 155.609 156.003 156.398 156.804 157.211 157.594 158.0 158.395 158.801 159.208 159.602 159.997 160.392 160.787 161.205 161.599 161.994 162.4 162.807 163.213 163.608 164.003 164.386 164.792 165.198 165.593 165.999 166.406 166.801 167.195 167.602 167.985 168.403 168.797 169.215 169.599 169.993 170.388 170.806 171.189 171.595 172.002 172.408 172.78 173.209 173.604 173.999 174.405 174.811 175.206 175.613 176.019 176.425 176.843 177.296 177.749 178.202 178.596 179.003 179.409 179.815 180.21 180.605 181.011 181.406 181.812 182.207 182.625 183.008 183.391 183.798 184.204 184.61 185.005 185.4 185.806 186.212 186.654 187.095 187.536 187.977 188.395 188.79 189.196 189.614 190.009 190.392 190.798 191.205 191.611 191.994 192.389 192.795 193.202 193.608 194.014 194.409 194.792 195.199 195.593 195.988 196.383 196.801 197.207 197.59 197.997 198.391 198.809 199.204 199.599 200.005 200.4 200.795 201.213 201.619 202.014 202.443 202.85 203.256 203.685 204.092 204.51 204.916 205.334 205.729 206.147 206.553 206.971 207.377 207.761 208.167 208.585 208.991 209.386 209.792 210.187 210.605 211.0 211.394 211.789 212.196 212.59 213.008 213.403 213.809 214.192 214.599 215.005 215.4 215.806 216.201 216.596 217.002 217.397 217.803 218.198 218.604 218.999 219.405 219.812 220.206 220.601 220.996 221.402 221.809 222.203 222.61 223.004 223.399 223.806 224.2 224.607 225.001 225.373 225.791 226.197 226.604 226.998 227.393 227.799 228.206 228.589 228.984 229.39 229.808 230.203 230.597 231.004 231.41 231.805 232.211 232.606 233.001 233.407 233.813 234.208 234.603 235.009 235.404 235.799 236.205 236.611 237.006 237.401 237.784 238.179 238.597 239.003 239.398 239.792 240.199 240.605 241.012 241.406 241.801 242.207 242.59 242.997 243.403 243.81 244.216 244.611 245.005 245.412 245.806 246.201 246.608 247.014 247.397 247.792 248.198 248.604 248.999 249.394 249.812 250.207 250.601 250.996 251.414 251.797 252.192 252.587 253.005 253.388 253.794 254.189 254.595 255.002 255.396 255.803 256.186 256.592 257.01 257.405 257.811 258.206 258.601 258.995 259.413 259.808 260.214 260.609 261.004 261.399 261.805 262.2 262.606 263.001 263.396 263.802 264.197 264.591 264.986 265.392 265.799 266.205 266.612 267.006 267.413 267.807 268.214 268.608 269.003 269.398 269.804 270.199 270.605 271.0 271.406 271.801 272.208 272.614 273.02 273.403 273.81 274.204 274.599 274.994 275.4 275.818 276.225 276.608 277.014 277.409 277.804 278.198 278.616 279.023 279.406 279.8 280.207 280.613 281.02 281.403 281.809 282.215 282.622 283.005))

; ROSパッケージをロード
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
        (move-foward '(0.3 0 0))
        (move-backward '(-0.3 0 0))
        (rotate-right '(0 0 2))
        (rotate-left '(0 0 -2))
        (move-right '(0 0.2 0))
        (move-left '(0 -0.2 0))
       )
    (case (mod counter 7)
      (0 stand-still)
      (1 move-right)
      (2 stand-still)
      (3 move-left)
      (4 stand-still)
      (5 rotate-left)
      (6 rotate-right)
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
