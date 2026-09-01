#!/usr/bin/env roseus

(load "package://jedy_bringup/euslisp/jedy-interface.l")
(jedy-init)

(defun calculate-beat-interval (bpm)
  "与えられたBPMに基づき、ビート間隔を秒で返す"
  (/ 60.0 bpm))  ;; BPMから間隔（秒）を計算

(setq bpm 90)

(setq beat-interval (calculate-beat-interval bpm)) ;; うなずきの間隔（秒単位で設定、今回は1.5秒）
(setq nod-position 30)   ;; うなずきの角度

;; 定期的に呼ばれるコールバック関数
(defun nod-head-callback ()
  (ros::ros-info "Nodding head...")
  
  ;; うなずき動作1：首を下げる
  (send *jedy* :head_joint0 :joint-angle nod-position)
  (send *jedy* :head_joint1 :joint-angle 90)
  (send *ri* :angle-vector (send *jedy* :angle-vector) 300)
  (send *ri* :wait-interpolation)

  ;; うなずき動作2：首を上げる
  (send *jedy* :head_joint0 :joint-angle 0)
  (send *jedy* :head_joint1 :joint-angle 0)
  (send *ri* :angle-vector (send *jedy* :angle-vector) 300)
  (send *ri* :wait-interpolation)
  
  (ros::ros-info "Waiting for next nod...")
)

;; Timerの作成：指定した間隔でコールバックを呼び出す
(defun start-timer ()
  (ros::create-timer 0.0 beat-interval #'nod-head-callback)　;;timer使えないらしい
  (ros::spin))

;; メイン処理を開始する
(start-timer)
