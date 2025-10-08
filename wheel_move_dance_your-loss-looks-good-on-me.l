#!/usr/bin/env roseus

(setq beat-times '(1.591 2.043 2.508 2.972 3.437 3.901 4.365 4.830 5.294 5.747 6.200 6.664 7.129 7.581 8.046 8.510 8.975 9.439 9.903 10.356 10.820 11.273 11.726 12.190 12.655 13.119 13.584 14.048 14.512 14.977 15.441 15.894 16.347 16.811 17.276 17.763 18.239 19.122 19.598 20.039 20.515 20.968 21.444 21.908 22.349 22.814 23.290 23.742 24.207 24.660 25.136 25.600 26.041 26.494 26.970 27.423 27.887 28.352 28.816 29.269 29.745 30.198 30.662 31.115 31.591 32.044 32.508 32.961 33.425 33.890 34.354 34.807 35.283 35.736 36.200 36.664 37.117 37.581 38.046 38.510 38.975 39.416 39.892 40.356 40.809 41.262 41.726 42.191 42.667 43.119 43.584 44.048 44.513 44.965 45.418 45.883 46.347 46.811 47.276 47.729 48.193 48.657 49.122 49.586 50.039 50.503 50.968 51.432 51.885 52.349 52.814 53.267 53.731 54.184 54.660 55.113 55.577 56.041 56.506 56.959 57.423 57.887 58.352 58.816 59.269 59.733 60.198 60.662 61.127 61.579 62.044 62.508 62.961 63.425 63.890 64.354 64.819 65.283 65.736 66.188 66.641 67.094 67.570 68.046 68.510 68.975 69.428 69.892 70.356 70.821 71.285 71.726 72.202 72.667 73.120 73.584 74.048 74.513 74.966 75.418 75.894 76.359 76.812 77.276 77.740 78.205 78.658 79.110 79.586 80.051 80.504 80.922 81.874 82.814 83.290 83.743 84.196 84.660 85.124 85.589 86.042 86.494 86.970 87.435 87.888 88.352 88.816 89.281 89.734 90.198 90.651 91.127 91.580 92.044 92.497 92.973 93.425 93.890 94.354 94.819 95.271 96.084 96.618 97.582 98.058 98.499 98.975 99.439 99.892 100.345 100.809 101.274 101.738 102.203 102.667 103.120 103.573 104.037 104.513 104.954 105.430 105.883 106.359 106.812 107.276 107.729 108.193 108.658 109.122 109.575 110.051 110.504 110.968 111.421 111.897 112.350 112.814 113.279 113.731 114.196 114.660 115.125 115.589 116.030 116.506 116.959 117.412 117.888 118.352 118.817 119.281 119.734 120.210 120.651 121.127 121.591 122.044 122.497 122.961 123.426 123.902 124.354 124.819 125.283 125.748 126.200 126.653 127.118 127.594 128.046 128.511 128.975 129.440 129.892 130.368 130.833 131.274 131.738 132.203 132.656 133.120 133.584 134.049 134.513 134.978 135.430 135.895 136.348 136.812 137.276 137.752 138.205 138.670 139.122 139.587 140.051 140.516 140.968 141.444 141.897 142.362 142.826 143.279 143.732 144.184 144.660 145.125 145.578 146.042 146.506 146.971 147.435 147.888 148.352 148.805 149.269 149.734 150.198 150.663 151.127 151.580 152.044 152.509 152.961 153.426 153.890 154.355 154.819 155.272 155.736 156.201 156.653 157.118 157.582 158.047 158.511 158.975 159.428 159.893 160.357 160.810 161.274 161.739 162.203 162.656 163.120 163.585 164.049 164.502 164.966 165.419 165.883 166.348 166.812 167.277 167.741 168.205 168.658 169.123 169.587 170.040 170.504 170.969 171.421 171.897 172.350 172.803 173.616 174.440 174.893) )

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
      (5 rotate-left)2
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