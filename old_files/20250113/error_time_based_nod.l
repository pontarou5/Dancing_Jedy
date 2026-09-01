#!/usr/bin/env roseus

(load "package://jedy_bringup/euslisp/jedy-interface.l")
(jedy-init)

;;(send *ri* :send-stretch :names '("rarm_joint0" "rarm_joint1" "larm_joint0" "larm_joint1") :value 64)
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

;; ビートタイミングとポーズを定義するリスト
(setq beat-times '(1.0 2.0 3.0 4.0 5.0 6.0 7.0 8.0 9.0 10.0
11.0 12.0 13.0 14.0 15.0 16.0 17.0 18.0 19.0 20.0
21.0 22.0 23.0 24.0 25.0 26.0 27.0 28.0 29.0 30.0
31.0 32.0 33.0 34.0 35.0 36.0 37.0 38.0 39.0 40.0
41.0 42.0 43.0 44.0 45.0 46.0 47.0 48.0 49.0 50.0
51.0 52.0 53.0 54.0 55.0 56.0 57.0 58.0 59.0 60.0)
)

;; ビート時刻とポーズのペアを格納する辞書型リスト
(setq beat-pose-dictionary '())

;; ランダムに関節角度を決定する関数
(defun random-pose ()
(mapcar #'(lambda (val) (random 10)) (make-list (length (send *jedy* :angle-vector))))
)
;; (defun random-pose ()
;;   (loop for i from 0 below (length (send *jedy* :angle-vector))
;;         collect (random 10))) ;; 適切な長さを生成

(defun alternating-pose ()
  "Return an alternating pose based on the current index."
  (let ((pose-1 '(89.91 -3.84749 -29.9362 -99.765 -2.93624 0.0 0.0 0.0 
                     99.8325 4.42126 29.835 -115.594 -87.615 0.0 0.0 0.0 
                     -1.005828e-05 -0.13501))
        (pose-2 '(-98.7525 -4.18499 -29.5987 -101.014 -2.59874 0.0 0.0 0.0 
                    -87.615 4.11751 29.835 -100.609 -87.9187 0.0 0.0 0.0 
                    -0.30376 -0.13501)))
    (if (evenp (random 2)) pose-1 pose-2))) ;; Return pose-1 if the random number is even, otherwise pose-2



;; ビート時刻とポーズをランダムに割り当ててディクショナリに保存
(dolist (beat-time beat-times)
  (let ((random-pose (alternating-pose)))
    (push (cons beat-time random-pose) beat-pose-dictionary)))

(setq beat-pose-dictionary (sort beat-pose-dictionary `(lambda (a b) (> (car a) (car b)))))

;; 現在処理したビートのインデックスを保持
(setq current-beat-index 0)

;; 時間差を取得し、次のビートの情報を返す関数
(defun get-time-difference (elapset-sec beat-list current-index)
  (let ((next-index (1+ current-index)))  ;; 次のインデックス
    (if (< next-index (length beat-list))  ;; 次のインデックスが有効な場合
        (let* ((next-beat (nth next-index beat-list))   ;; 次のビート時刻とポーズ
               (next-time (car next-beat))               ;; 次のビート時刻
               (next-pose (cdr next-beat)))              ;; 次のポーズ
          ;; 次のビートとの時間差を計算
          (list (- next-time elapset-sec) next-time next-pose next-index))
        nil)))  ;; 次のビートがない場合は nil を返す

;; 初期時刻を取得
(setq start-time (ros::time-now))

;; 実行部分、進行状況をインデックスで管理
(ros::rate 20)
(do-until-key
  (let* ((current-time (ros::time-now))
         (elapsed-sec (- (send current-time :to-sec)
                         (send start-time :to-sec))))
    ; (ros::ros-info "Elapsed Time: ~A seconds" elapsed-sec)

    ;; 次のビートの情報を取得
    (setq time-difference-with-pose (get-time-difference elapsed-sec (reverse beat-pose-dictionary) current-beat-index))
    (if time-difference-with-pose
        (let ((time-diff (nth 0 time-difference-with-pose))
              (next-beat (nth 1 time-difference-with-pose))
             (pose (remove-if #'null (nth 2 time-difference-with-pose)));; なぜか含まれるnilを取り除く

              (new-index (nth 3 time-difference-with-pose)))  ;; 新しいインデックス

          (ros::ros-info "Elapsed Time: ~A seconds" elapsed-sec)
          (ros::ros-info "after-calc-time-diff: ~A seconds" (- (send (ros::time-now) :to-sec) (send start-time :to-sec)))

          ;; 次のビートの情報とポーズを送信
          (ros::ros-info "Next Beat at ~A seconds: Pose ~A" next-beat pose)
          (send *jedy* :angle-vector pose)

          ;; 次のビートを送信した後にインデックスを更新
          (setq current-beat-index new-index)
          (ros::ros-info "Sending angle vector with time diff: ~A" time-diff)

          ;; 時刻差に応じて補間(* 1000 time-diff)、wait-interpolation
          (ros::ros-info "before-move: ~A seconds" (- (send (ros::time-now) :to-sec) (send start-time :to-sec)))
          ; (send *ri* :angle-vector (send *jedy* :angle-vector) (* 1000 time-diff) :default-controller 0 :min-time 0.1)
          (send *ri* :angle-vector (send *jedy* :angle-vector) (* 1000 1.0) :default-controller 0 :min-time 0.1)

          (ros::ros-info "after-move: ~A seconds" (- (send (ros::time-now) :to-sec) (send start-time :to-sec)))
          (send *ri* :wait-interpolation)
          (ros::ros-info "after-wait: ~A seconds" (- (send (ros::time-now) :to-sec) (send start-time :to-sec)))
 
  ;; 終了待機状態
  (ros::ros-info "Waiting for key press...")))))
