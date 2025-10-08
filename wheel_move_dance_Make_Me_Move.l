#!/usr/bin/env roseus

(setq beat-times '(0.035 0.666 1.298 1.929 2.561 3.192 3.824 4.455 5.087 5.718 6.350 6.981 7.613 8.244 8.876 9.507 10.139 10.770 11.402 12.033 12.664 13.296 13.927 14.559 15.163 15.824 16.417 17.090 17.717 18.344 18.959 19.609 20.236 20.852 21.478 22.129 22.756 23.394 24.033 24.660 25.287 25.913 26.540 27.191 27.818 28.456 29.083 29.722 30.325 30.975 31.614 32.229 32.868 33.506 34.145 34.760 35.399 36.026 36.664 37.291 37.918 38.557 39.195 39.822 40.438 41.076 41.715 42.342 42.969 43.607 44.246 44.861 45.488 46.126 46.765 47.392 48.030 48.669 49.284 49.911 50.550 51.177 51.804 52.442 53.081 53.696 54.323 54.973 55.612 56.239 56.866 57.504 58.131 58.770 59.397 60.024 60.662 61.289 61.928 62.555 63.193 63.808 64.459 65.086 65.701 66.200 66.827 67.454 68.093 68.719 69.358 70.101 70.751 71.250 71.877 72.632 73.282 73.898 74.408 75.024 75.662 76.289 76.928 77.555 78.193 78.820 79.459 80.213 80.863 81.479 81.990 82.744 83.406 83.998 84.509 85.136 85.775 86.401 87.028 87.655 88.445 89.049 89.559 90.314 90.964 91.614 92.241 92.880 93.518 94.145 94.784 95.399 96.049 96.665 97.292 97.919 98.557 99.184 99.811 100.438 101.076 101.703 102.330 102.969 103.596 104.234 104.873 105.500 106.138 106.765 107.392 108.031 108.658 109.285 109.772 110.539 111.154 111.816 112.454 113.070 113.697 114.347 114.985 115.601 116.227 116.866 117.505 118.143 118.758 119.397 120.036 120.651 121.278 121.916 122.555 123.182 123.809 124.447 125.098 125.713 126.340 126.967 127.605 128.232 128.871 129.509 130.183 130.856 131.402 132.029 132.644 133.283 133.933 134.548 135.175 135.814 136.452 137.091 137.729 138.356 138.995 139.645 140.272 140.887 141.502 142.141 142.768 143.406 144.033 144.649 145.299 145.926 146.553 147.040 147.667 148.294 148.933 149.560 150.198 150.941 151.591 152.091 152.718 153.472 154.134 154.738 155.249 155.864 156.502 157.141 157.768 158.395 159.033 159.660 160.299 161.054 161.715 162.319 162.830 163.585 164.235 164.838 165.349 165.976 166.615 167.230 167.869 168.507 169.134 169.761 170.400 171.166) )

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