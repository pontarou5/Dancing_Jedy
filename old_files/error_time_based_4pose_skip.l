#!/usr/bin/env roseus

(load "package://jedy_bringup/euslisp/jedy-interface.l")
(jedy-init)

;; 必要なロボット設定
(send *ri* :send-stretch :names '("rarm_joint0" "rarm_joint1" "rarm_joint2" "rarm_joint3"
                                   "rarm_joint4" "rarm_joint5" "rarm_joint6" "rarm_gripper_joint"
                                   "larm_joint0" "larm_joint1" "larm_joint2" "larm_joint3"
                                   "larm_joint4" "larm_joint5" "larm_joint6" "larm_gripper_joint"
                                   "head_joint0" "head_joint1" "front_right_wheel_joint"
                                   "front_left_wheel_joint" "rear_right_wheel_joint"
                                   "rear_left_wheel_joint")
      :value '(64 64 64 64 127 127 127 127 127 127 127 127 127 127 127 127))

(send (send *ri* :read-stretch) :slots)

(send *ri* :servo-on)

;; 進行状況の時刻リスト（beat_times）と関連付けられたポーズ
(setq beat-times '(14.617 15.360 16.091 16.823 17.578 18.321 19.075 19.807 20.550 21.281 22.013 22.756 23.510
                   24.242 24.973 25.728 26.471 27.214 27.945 28.688 29.431 30.174 30.929 31.660 32.403 33.135
                   33.878 34.621 35.352 36.107 36.838 37.593 38.325 39.068 39.962 40.542 41.285 42.017 42.771
                   43.503 44.246 44.989 45.732 46.463 47.206 47.949 48.692 49.447 50.178 50.921 51.664 52.407
                   53.139 53.870 54.625 55.356 56.099 56.842 57.574 58.329 59.060))

(setq beat-pose-dictionary '())

(defun alternating-pose (counter)
  "Return an alternating pose based on the current index (counter mod 4)."
  (let ((pose-1 '(89.91 -3.84749 -29.9362 -99.765 -2.93624 0.0 0.0 0.0 
                     99.8325 4.42126 29.835 -115.594 -87.615 0.0 0.0 0.0 
                     -1.005828e-05 -0.13501))
        (pose-2 '(-98.7525 -4.18499 -29.5987 -101.014 -2.59874 0.0 0.0 0.0 
                    -7.615 4.11751 29.835 -100.609 -87.9187 0.0 0.0 0.0 
                    -0.30376 -0.13501))
        (pose-3 '(-80.19 -93.6225 -0.13499 0.13501 0.30376 0.0 0.0 0.0 -15.39 63.8888 -68.3775 -107.123 0.13501 0.0 0.0 0.0 -58.4213 -0.13501))
        (pose-4 '(-80.19 -93.6225 -0.13499 -132.57 0.64126 0.0 0.0 0.0 -15.39 64.2263 -68.3775 -107.123 0.13501 0.0 0.0 0.0 -7.32376 -0.13501)
))
    (case (mod counter 4)
      (0 pose-1)
      (1 pose-2)
      (2 pose-3)
      (3 pose-4))))

;; ビートに対応するポーズを定義
(setq *pose-counter* 0)
(dolist (beat-time beat-times)
    (setf *counter-pose* (+ 1 *counter-pose*))
  (let ((random-pose (alternating-pose *counter-pose*)))
    (push (cons beat-time random-pose) beat-pose-dictionary)))

(setq beat-pose-dictionary (sort beat-pose-dictionary `(lambda (a b) (> (car a) (car b)))))
(ros::ros-info "~A" beat-pose-dictionary)

;; 時刻でビートの対応ポーズを取得する関数
(defun get-pose-for-beat (current-time)
  "Returns the pose for the nearest beat based on the current music time."
  (let ((nearest-beat (car (sort beat-pose-dictionary
                                (lambda (a b)
                                  (< (abs (- current-time (car a)))
                                     (abs (- current-time (car b)))))))))
    (cdr nearest-beat)))

;; 進行時刻を受け取るためにROSのサブスクライバを設定
(ros::subscribe "/audio/current_position" 
               (lambda (msg)
                 (let ((current-time (send msg :data)))  ;; メッセージから現在の時刻を取得
                   (let ((pose (get-pose-for-beat current-time)))
                     (send *jedy* :angle-vector pose)
                     (ros::ros-info "Updated pose at time ~A: ~A" current-time pose)))))

;; ROSノードと実行部分
(ros::rate 20)
(do-until-key
    (progn
        (ros::ros-info "Waiting for music timing updates...")
    )
)
