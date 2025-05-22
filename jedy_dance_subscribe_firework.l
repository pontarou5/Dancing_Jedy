#!/usr/bin/env roseus

(setq beat-pose-dictionary '(
  (29.071 -92.9812 -75.87 2.39626 -50.8275 0.0 0.0 0.0 0.0 79.5487 -5.09626 1.48499 -115.087 0.0 0.0 0.0 0.0 0.0 16.0625)

  (188.082 -92.6437 -56.0925 -75.8025 48.2625 0.0 0.0 0.0 0.0 126.596 5.46749 0.13499 -42.8625 0.0 0.0 0.0 0.0 0.0 16.0625)
))

(setq beat-times '(29.071 29.455 29.826 30.209 30.581 30.952 31.335 31.707 32.067 32.45 32.833 33.193 33.576 33.948 34.331 34.702 35.085 35.457 35.84 36.188 36.583 36.955 37.326 37.698 38.081 38.452 38.835 39.195 39.578 39.95 40.333 40.705 41.076 41.459 41.831 42.214 42.585 42.957 43.328 43.7 44.071 44.455 44.826 45.209 45.592 45.964 46.335 46.707 47.078 47.45 47.821 48.205 48.576 48.948 49.319 49.691 50.062 50.434 50.805 51.177 51.56 51.943 52.326 52.698 53.069 53.441 53.824 54.195 54.602 54.962 55.356 55.728 56.076 56.459 56.831 57.202 57.585 57.957 58.34 58.712 59.06 59.42 59.838 60.209 60.592 60.952 61.336 61.73 62.102 62.45 62.833 63.193 63.588 63.959 64.331 64.714 65.086 65.457 65.829 66.2 66.583 66.955 67.326 67.721 68.093 68.452 68.836 69.195 69.579 69.962 70.333 70.705 71.076 71.448 71.831 72.202 72.574 72.957 73.317 73.7 74.083 74.455 74.838 75.209 75.581 75.952 76.336 76.719 77.102 77.473 77.845 78.216 78.6 78.983 79.343 79.714 80.086 80.457 80.84 81.223 81.595 81.966 82.338 82.709 83.093 83.464 83.836 84.207 84.579 84.95 85.322 85.693 86.076 86.448 86.819 87.191 87.562 87.934 88.305 88.677 89.06 89.432 89.815 90.198 90.581 90.976 91.324 91.684 92.079 92.45 92.822 93.193 93.576 93.96 94.331 94.703 95.074 95.446 95.829 96.212 96.572 96.955 97.338 97.71 98.081 98.453 98.824 99.207 99.59 99.95 100.333 100.693 101.076 101.46 101.831 102.191 102.574 102.946 103.317 103.7 104.083 104.455 104.826 105.21 105.57 105.953 106.336 106.696 107.09 107.462 107.845 108.205 108.588 108.96 109.331 109.703 110.086 110.457 110.829 111.189 111.583 111.955 112.327 112.698 113.081 113.453 113.824 114.184 114.579 114.95 115.334 115.705 116.077 116.46 116.831 117.214 117.609 117.992 118.375 118.758 119.13 119.513 119.861 120.198 120.581 120.953 121.336 121.707 122.079 122.45 122.822 123.205 123.577 123.96 124.331 124.703 125.074 125.446 125.829 126.2 126.572 126.955 127.327 127.71 128.081 128.453 128.836 129.207 129.579 129.962 130.334 130.705 131.077 131.448 131.831 132.203 132.563 132.946 133.329 133.689 134.049 134.42 134.792 135.163 135.535 135.906 136.29 136.673 137.056 137.427 137.799 138.182 138.553 138.925 139.297 139.68 140.051 140.434 140.806 141.177 141.549 141.92 142.292 142.663 143.047 143.43 143.801 144.173 144.556 144.939 145.322 145.694 146.077 146.46 146.831 147.203 147.574 147.946 148.317 148.689 149.06 149.432 149.804 150.175 150.547 150.93 151.313 151.696 152.079 152.451 152.834 153.205 153.588 153.96 154.331 154.703 155.086 155.469 155.841 156.201 156.572 156.944 157.327 157.71 158.081 158.453 158.824 159.196 159.579 159.951 160.334 160.705 161.077 161.448 161.831 162.203 162.586 162.969 163.341 163.689 164.072 164.467 164.827 165.21 165.593 165.953 166.336 166.708 167.091 167.462 167.834 168.205 168.565 168.925 169.297 169.668 170.051 170.446 170.829 171.201 171.549 171.932 172.327 172.698 173.07 173.441 173.825 174.196 174.591 174.974 175.345 175.717 176.089 176.46 176.832 177.203 177.586 177.958 178.329 178.701 179.084 179.455 179.839 180.198 180.593 180.953 181.325 181.696 182.091 182.462 182.834 183.205 183.577 183.948 184.308 184.692 185.086 185.458 185.841 186.212 186.596 186.967 187.339 187.699 188.082 189.591))

(setq smoothness 0.9)

;; 結果を出力
(print "Converted beat-times:")
(print beat-times)
(print "Converted beat-pose-dictionary:")
(print beat-pose-dictionary)




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


(ros::ros-info "~A" beat-pose-dictionary)


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

(defun get-next-info (current-position beat-pose-dictionary current-index current-beat smoothness)
  "Returns the information for the next beat if the current position is close to the current beat."
  (let* ((current-beat-and-pose (nth current-index beat-pose-dictionary)) ;; 現在のビート情報
         (tolerance 0.1)) ;; 許容誤差（例: 100ms）
    
    ; ; 変数の状態を出力
    ; (format t "DEBUG: current-position=~A, current-beat=~A, current-index=~A~%"
    ;         current-position current-beat current-index)
    
    ;; 近いビートがあるかどうかを確認
    (if (or (<= (abs (- current-position current-beat)) tolerance) ;; 最初のビートも許容
            (= current-index 0))                                 ;; 最初のビートを強制的に処理
        (progn
          (format t "DEBUG: Close enough or first beat - checking next beat~%")
          ; (let ((next-index (1+ current-index))) ;; 次のインデックスを計算
          (let ((next-index (+ 1 current-index))) ;; 次のインデックスを計算

            ;; 次のインデックスが範囲内か確認
            (if (< next-index (length beat-pose-dictionary))
                (let* ((next-beat-and-pose (nth next-index beat-pose-dictionary)) ;; 次のビート情報
                       (next-time (car next-beat-and-pose))                        ;; 次のビート時刻
                       (next-pose (cdr next-beat-and-pose)))                       ;; 次のビートのポーズ
                  ;; 結果を計算して返す
                  (format t "DEBUG: Found next beat at index ~A: next-time=~A, next-pose=~A~%"
                          next-index next-time next-pose)
                  (list (* smoothness (- next-time current-position)) next-time next-pose next-index))
                ;; 次のインデックスが範囲外の場合のログ
                (progn
                  ; (format t "DEBUG: Next index (~A) is out of range~%" next-index)
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
      (let* ((current-index-and-beat  (set-current-index *current-position* beat-times))
            (current-index  (car current-index-and-beat))
            (current-beat (first (cdr current-index-and-beat))))
        ; (ros::ros-info "current-index: ~A" current-index)

        ;;次のビートの情報を取得
        (setq next-info-list (get-next-info *current-position* beat-pose-dictionary current-index current-beat smoothness))
        (if next-info-list
            (let ((time-diff (nth 0 next-info-list))
                  (next-beat (nth 1 next-info-list))
                  (pose (remove-if #'null (nth 2 next-info-list)));; なぜか含まれるnilを取り除く
                  (next-index (nth 3 next-info-list)))  ;; 新しいインデックス

              ; (ros::ros-info "*current-position*: ~A seconds" *current-position*)

              ; 次のビートの情報とポーズを送信
              (ros::ros-info "next-index: ~A | next-beat: ~A | seconds pose:~A " next-index next-beat pose)
              (ros::ros-info "time-diff: ~A" time-diff)
              (when *use-robot* (send *jedy* :angle-vector pose))

              ;; 時刻差に応じて補間(* 1000 time-diff)、wait-interpolation
              (when *use-robot*
                ; (ros::ros-info "before-move: ~A seconds" (- (send (ros::time-now) :to-sec) (send start-time :to-sec)))
                (send *ri* :angle-vector (send *jedy* :angle-vector) time-diff :default-controller 0 :min-time 0.1)
                ;; (ros::ros-info "after-move: ~A seconds" (- (send (ros::time-now) :to-sec) (send start-time :to-sec)))
                (send *ri* :wait-interpolation)
                ;; (ros::ros-info "after-wait: ~A seconds" (- (send (ros::time-now) :to-sec) (send start-time :to-sec)))
              )
    
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