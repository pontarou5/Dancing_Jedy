#!/usr/bin/env roseus

(load "package://jedy_bringup/euslisp/jedy-interface.l")
(jedy-init)
(send *ri* :servo-on)

(defun calculate-beat-interval (bpm)
  "与えられたBPMに基づき、ビート間隔を秒で返す"
  (/ 60.0 bpm))  ;; BPMから間隔（秒）を計算

(setq bpm 120)

(setq beat-interval (calculate-beat-interval bpm)) ;; うなずきの間隔（秒単位で設定、今回は0.66666秒）
(setq nod-position 0)   ;; うなずきの角度

(setq current-time (ros::time-now))  ;; 現在時刻を取得

;; ビートタイミングに合わせてうなずき動作を実行する関数
(defun nod-head (elapsed-time)
  (if (< (mod elapsed-time beat-interval) 0.1) ;; 0.1秒以内の許容範囲でビートと一致
      (progn
        (ros::ros-info "Nodding head...")
        ;; うなずき動作1：首を下げる
        (send *jedy* :head_joint0 :joint-angle nod-position)
        (send *jedy* :head_joint1 :joint-angle 30)
        (send *ri* :angle-vector (send *jedy* :angle-vector) 300)
        (send *ri* :wait-interpolation)

        ;; うなずき動作2：首を上げる
        (send *jedy* :head_joint0 :joint-angle 0)
        (send *jedy* :head_joint1 :joint-angle 0)
        (send *ri* :angle-vector (send *jedy* :angle-vector) 300)
        (send *ri* :wait-interpolation)
        (ros::ros-info "Waiting for next nod..."))))

;; 時間経過に従ってうなずき動作を呼ぶループ
(defun start-beat-loop ()
  (setq start-time (ros::time-now))
  (loop
    (setq current-time (ros::time-now))
    (let ((elapsed-time (- (send current-time :to-sec)
                           (send start-time :to-sec)))) ;; 経過時間を計算
      (nod-head elapsed-time))  ;; ビートタイミングに合わせて首を動かす
    (ros::sleep 0.05)))  ;; 0.05秒ごとにチェック

(start-beat-loop)  ;; メインのループを開始
