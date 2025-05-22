#!/usr/bin/env roseus

yet editted !!!
(setq beat-times '(11.831 12.283 12.794 13.607 14.048 14.559 15.372 15.836 16.335 17.136 17.601 18.042 18.495 18.936 19.377 19.83 20.271 20.724 21.153 21.618 22.059 22.489 22.941 23.406 23.835 24.276 24.718 25.17 25.612 26.053 26.494 26.935 27.376 27.829 28.27 28.735 29.164 29.605 30.047 30.511 30.941 31.393 31.835 32.287 32.717 33.17 33.611 34.064 34.493 34.946 35.387 35.84 36.281 36.722 37.164 37.616 38.058 38.499 38.94 39.381 39.834 40.275 40.716 41.169 41.61 42.051 42.504 42.945 43.386 43.828 44.28 44.733 45.163 45.616 46.057 46.498 46.939 47.392 47.845 48.286 48.727 49.168 49.609 50.051 50.492 50.933 51.397 51.839 52.28 52.721 53.174 53.615 54.044 54.474 54.927 55.368 55.821 56.262 56.692 57.133 57.585 58.05 58.491 58.944 59.397 59.826 60.279 60.72 61.161 61.591 62.044 62.508 62.938 63.39 63.832 64.284 64.726 65.167 65.62 66.049 66.502 66.943 67.396 67.895 68.719 69.161 69.613 70.055 70.496 70.925 71.413 71.831 72.272 72.725 73.166 73.607 74.048 74.501 74.942 75.395 75.825 76.278 76.73 77.16 77.624 78.042 78.507 78.936 79.389 79.83 80.353 81.165 81.595 82.036 82.489 82.93 83.383 83.824 84.277 84.706 85.159 85.612 86.053 86.471 86.936 87.458 88.282 88.723 89.234 90.059 90.5 91.011 91.835 92.323 92.787 93.611 94.052 94.575 95.399 95.84 96.282 96.723 97.164 97.605 98.058 98.499 98.94 99.393 99.834 100.264 100.717 101.158 101.611 102.04 102.493 102.934 103.387 103.84 104.269 104.722 105.163 105.593 106.034 106.487 106.928 107.392 107.833 108.275 108.716 109.169 109.61 110.051 110.492 110.922 111.386 111.839 112.28 112.733 113.174 113.615 114.056 114.498 114.95 115.392 115.844 116.286 116.727 117.168 117.621 118.05 118.491 118.967 119.409 119.838 120.256 120.721 121.162 121.615 122.044 122.485 122.926 123.391 123.832 124.273 124.726 125.167 125.62 126.05 126.491 126.943 127.396 127.826 128.279 128.72 129.161 129.602 130.055 130.496 130.949 131.39 131.843 132.272 132.714 133.166 133.608 134.037 134.49 134.943 135.384 135.814 136.266 136.707 137.149 137.59 138.054 138.495 139.006 139.831 140.272 140.725 141.166 141.607 142.048 142.501 142.942 143.383 143.824 144.277 144.718 145.16 145.601 146.042 146.495 146.936 147.389 147.841 148.283 148.724 149.165 149.618 150.059 150.5 150.953 151.394 151.835 152.276 152.729 153.182 153.612 154.053 154.506 154.958 155.388 155.841 156.282 156.735 157.176 157.617 158.058 158.511 158.952 159.393 159.846 160.287 160.729 161.17 161.622 162.064 162.505 162.946 163.399 163.84 164.281 164.722 165.164 165.616 166.058 166.51 166.951 167.404 167.845 168.275 168.728 169.181 169.61 170.063 170.516 170.957 171.398 171.828 172.28 172.733 173.174 173.616 174.068 174.51 174.951 175.38 175.845 176.286 176.727 177.168 177.609 178.062 178.503 178.945 179.386 179.839 180.28 180.721 181.174 181.603 182.044 182.486 182.915 183.368 183.821 184.262 184.703 185.144 185.585 186.05 186.491 186.944 187.385 187.826 188.267 188.709 189.161 189.603 190.044 190.473 190.926 191.367 191.832 192.273 192.714 193.167 193.62 194.038 194.467 195.28 195.791 196.255 196.696 197.149 197.59 198.043 198.484 198.914 199.355 199.819 200.272 200.725 201.166 201.607 202.06 202.49 202.931 203.384 203.825 204.278 204.73 205.16 205.613 206.054 206.507 206.936 207.389 207.83 208.329 209.165 209.607 210.106 210.942 211.371 211.824 212.265 212.706 213.148 213.6 214.053 214.483 214.936 215.388 215.829 216.271 216.723 217.176 217.606 218.059 218.5 218.953 219.382 219.835 220.276 220.787 221.623 222.052 222.505 222.935 223.376 223.806 224.282 224.723 225.152 225.617 226.128 226.94 227.393 227.892 228.717 229.169 229.669 230.493 230.934 231.375 231.828))



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