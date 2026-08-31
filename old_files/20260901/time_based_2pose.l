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
(setq beat-times '(14.617 15.360 16.091 16.823 17.578 18.321 19.075 19.807 20.550 21.281 22.013 22.756 23.510 24.242 24.973 25.728 26.471 27.214 27.945 28.688 29.431 30.174 30.929 31.660 32.403 33.135 33.878 34.621 35.352 36.107 36.838 37.593 38.325 39.068 39.962 40.542 41.285 42.017 42.771 43.503 44.246 44.989 45.732 46.463 47.206 47.949 48.692 49.447 50.178 50.921 51.664 52.407 53.139 53.870 54.625 55.356 56.099 56.842 57.574 58.329 59.060)
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

; (defvar *pose-counter* 0)  ;; 交互にするためのカウンタを定義

(defun alternating-pose (counter)
  "Return an alternating pose based on the current index."
  (let ((pose-1 '(89.91 -3.84749 -29.9362 -99.765 -2.93624 0.0 0.0 0.0 
                     99.8325 4.42126 29.835 -115.594 -87.615 0.0 0.0 0.0 
                     -1.005828e-05 -0.13501))
        (pose-2 '(-98.7525 -4.18499 -29.5987 -101.014 -2.59874 0.0 0.0 0.0 
                    -87.615 4.11751 29.835 -100.609 -87.9187 0.0 0.0 0.0 
                    -0.30376 -0.13501)))
    ; (setq *pose-counter* (+ 1 *pose-counter*))  ;; カウンタを1増やす
    (if (evenp counter) pose-1 pose-2))) ;; カウンタが偶数ならpose-1, 奇数ならpose-2を返す



;; ビート時刻とポーズをランダムに割り当ててディクショナリに保存
; (dolist (beat-time beat-times)
;   (let ((random-pose (alternating-pose)))
;     (push (cons beat-time random-pose) beat-pose-dictionary)))
(setq *counter-pose* 0)
(dolist (beat-time beat-times)
    (setf *counter-pose* (+ 1 *counter-pose*))
  (let ((random-pose (alternating-pose *counter-pose*)))
    (push (cons beat-time random-pose) beat-pose-dictionary)))

(setq beat-pose-dictionary (sort beat-pose-dictionary `(lambda (a b) (> (car a) (car b)))))
(ros::ros-info "~A" beat-pose-dictionary)

;; 現在処理したビートのインデックスを保持
(setq current-beat-index 0)

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
        nil)))    

;; 初期時刻を取得
(setq start-time (ros::time-now))

;; 実行部分、進行状況をインデックスで管理
(ros::rate 20)
(do-until-key
  (let* ((current-time 0)
         (elapsed-sec 0))
    (setf current-time (ros::time-now))
    (setf elapsed-sec (- (send current-time :to-sec)
                         (send start-time :to-sec)))
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
          (ros::ros-info "if is OK!!")
          ;; 次のビートの情報とポーズを送信
          (ros::ros-info "Next Beat at ~A seconds: Pose ~A" next-beat pose)
          (send *jedy* :angle-vector pose)

          ;; 次のビートを送信した後にインデックスを更新
          (setq current-beat-index new-index)
          (ros::ros-info "Sending angle vector with time diff: ~A" time-diff)

          ;; 時刻差に応じて補間(* 1000 time-diff)、wait-interpolation
          (ros::ros-info "before-move: ~A seconds" (- (send (ros::time-now) :to-sec) (send start-time :to-sec)))
          (send *ri* :angle-vector (send *jedy* :angle-vector) (* 900 time-diff) :default-controller 0 :min-time 0.1)
        ;   (send *ri* :angle-vector (send *jedy* :angle-vector) (* 1000 0.1) :default-controller 0 :min-time 0.1)

          (ros::ros-info "after-move: ~A seconds" (- (send (ros::time-now) :to-sec) (send start-time :to-sec)))
          (send *ri* :wait-interpolation)
          (ros::ros-info "after-wait: ~A seconds" (- (send (ros::time-now) :to-sec) (send start-time :to-sec)))
 
  ;; 終了待機状態
  (ros::ros-info "Waiting for key press..."))
  (progn
    (ros::ros-info "if is not OK!!")
    (ros::ros-info "time-now :~A seconds" (- (send (ros::time-now) :to-sec) (send start-time :to-sec)))
  )
  )))
