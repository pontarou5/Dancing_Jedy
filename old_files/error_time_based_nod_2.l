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
(setq beat-pose-dictionary '(
(1.0 #f(89.91 -3.84749 -29.9362 -99.765 -2.93624 0.0 0.0 0.0 99.8325 4.42126 29.835 -115.594 -87.615 0.0 0.0 0.0 -1.005828e-05 -0.13501))
(2.0 #f(0.0 0.0 0.0 0.0 0.0 0.0 0.0 0.0 0.0 0.0 0.0 0.0 0.0 0.0 0.0 0.0 0.0 0.0))
(3.0 #f(-98.7525 -4.18499 -29.5987 -101.014 -2.59874 0.0 0.0 0.0 -87.615 4.11751 29.835 -100.609 -87.9187 0.0 0.0 0.0 -0.30376 -0.13501))
(4.0 #f(0.0 0.0 0.0 0.0 0.0 0.0 0.0 0.0 0.0 0.0 0.0 0.0 0.0 0.0 0.0 0.0 0.0 0.0))
(5.0 #f(89.91 -3.84749 -29.9362 -99.765 -2.93624 0.0 0.0 0.0 99.8325 4.42126 29.835 -115.594 -87.615 0.0 0.0 0.0 -1.005828e-05 -0.13501))
)
)


(setq beat-pose-dictionary (sort beat-pose-dictionary `(lambda (a b) (> (car a) (car b)))))

;; 現在処理したビートのインデックスを保持
(setq current-beat-index 0)

;; 時間差を取得し、次のビートの情報を返す関数
; (defun get-time-difference (elapsed-sec beat-list current-index)
;   (let* ((current-beat (nth current-index beat-list))   ;; 現在のビート
;          (current-time (car current-beat))             ;; 現在のビートの時刻
;          (tolerance 0.05))                             ;; 許容誤差（例: 50ms）
;     (if (and (<= (abs (- elapsed-sec current-time)) tolerance)) ;; 十分に近いか確認
;         (let ((next-index (1+ current-index)))         ;; 次のインデックス
;           (if (< next-index (length beat-list))        ;; 次のインデックスが有効か確認
;               (let* ((next-beat (nth next-index beat-list)) ;; 次のビート
;                      (next-time (car next-beat))           ;; 次のビート時刻
;                      (next-pose (cdr next-beat)))          ;; 次のビートのポーズ
;                 ;; 時間差を計算して結果を返す
;                 (list (- next-time elapsed-sec) next-time next-pose next-index))
;               nil))                                     ;; 次のビートがない場合は nil を返す
;         nil)))                                         ;; 時刻が近くない場合も nil を返す

(defun get-time-difference (elapsed-sec beat-list current-index)
  (let* ((current-beat (nth current-index beat-list))   ;; 現在のビート
         (current-time (car current-beat))               ;; 現在のビートの時刻
         (tolerance 0.05))                               ;; 許容誤差（例: 50ms）
    (if (or (<= (abs (- elapsed-sec current-time)) tolerance)  ;; 最初のビートは「近い」時刻差もOK
            (= current-index 0))                         ;; 最初のビートを強制的に処理
        (let ((next-index (1+ current-index)))           ;; 次のインデックス
          (if (< next-index (length beat-list))          ;; 次のインデックスが有効か確認
              (let* ((next-beat (nth next-index beat-list)) ;; 次のビート
                     (next-time (car next-beat))           ;; 次のビート時刻
                     (next-pose (cdr next-beat)))          ;; 次のビートのポーズ
                ;; 時間差を計算して結果を返す
                (list (- next-time elapsed-sec) next-time next-pose next-index))
              nil))                                       ;; 次のビートがない場合は nil を返す
        nil)))                                            ;; 時刻が近くない場合も nil を返す

;;一旦init-poseを取らせる
(send *ri* :angle-vector #f(0.0 0.0 0.0 0.0 0.0 0.0 0.0 0.0 0.0 0.0 0.0 0.0 0.0 0.0 0.0 0.0 0.0 0.0) 5000 :default-controller 0 :min-time 0.5)
(ros::ros-info "init-posion-1")
(send *ri* :wait-interpolation)
(send *ri* :angle-vector #f(89.91 -3.84749 -29.9362 -99.765 -2.93624 0.0 0.0 0.0 99.8325 4.42126 29.835 -115.594 -87.615 0.0 0.0 0.0 -1.005828e-05 -0.13501) 5000 :default-controller 0 :min-time 0.5)
(ros::ros-info "init-posion-2")
(send *ri* :wait-interpolation)
;; 初期時刻を取得
(setq start-time (ros::time-now))

;; 実行部分、進行状況をインデックスで管理
(ros::rate 20)s
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

              
          ;; 次のビートの情報とポーズを送信
          (ros::ros-info "Next Beat at ~A seconds: Pose ~A" next-beat pose)
          ; (send *jedy* :angle-vector pose)

          ;; 次のビートを送信した後にインデックスを更新
          (setq current-beat-index new-index)
          ; (ros::ros-info "Sending angle vector with time diff: ~A" time-diff)

          ; ;; 時刻差に応じて補間(* 1000 time-diff)、wait-interpolation
          ; (send *ri* :angle-vector (send *jedy* :angle-vector) (* 1000 time-diff) :default-controller 0 :min-time 0.1)
          ; (send *ri* :wait-interpolation)
 
  ;; 終了待機状態
  ; (ros::ros-info "Waiting for key press...")
  (if (== current-beat-index (- (length beat-list) 1))
              (do-until-key (break) nil))
  )))
  
  )