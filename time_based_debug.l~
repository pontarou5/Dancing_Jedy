#!/usr/bin/env roseus

(load "package://jedy_bringup/euslisp/jedy-interface.l")
(jedy-init)

(send *ri* :send-stretch :names '("rarm_joint0" "rarm_joint1" "larm_joint0" "larm_joint1") :value 64)
(send (send *ri* :read-stretch) :slots)

(send *ri* :servo-on)

;; ビート時刻と対応するポーズ指示のセットを辞書型で定義
(setq beat-times '(0 4.725 5.236 5.735 6.234 6.745 7.256 7.767 8.277 8.788 9.299
		     9.810 10.321 10.820 11.331 11.842 12.353 12.863 13.363 13.873 
		     14.384 14.895 15.406 15.905 16.416 16.927 17.334 17.775 18.204
		     18.704 19.214 19.725 20.236 20.747 21.246 21.757 22.268 22.767
		     23.278 23.788 24.299 24.799 25.321 25.821 26.331 26.842 27.353
		     27.864 28.363 28.874 29.385 29.896 30.406 30.906 31.417 31.927
		     32.427 32.938 33.448 33.959 34.470 34.981 35.492 36.003 36.502
		     37.013 37.523 38.023 38.534 39.044 39.555 40.066 40.565 41.076
		     41.587 42.098 42.609 43.108 43.619 44.130 44.640 45.140 45.662
		     46.161 46.672 47.183 47.682 48.193 48.704 49.215 49.726 50.236
		     50.747 51.258 51.757 52.268 52.779 53.290 53.789 54.300 54.811
		     55.310 55.821 56.332 56.842 57.353 57.864 58.375 58.874 59.385))

;; 各ビート時刻にランダムにポーズを割り当て
(setq beat-pose-dictionary '())

;; ランダムに関節角度を決定する関数 (0.0〜85.0の範囲でランダムな小数を生成)
(defun random-pose ()
  ;; 角度のリストを生成 (各値は 0.0 から 85.0 の範囲でランダムな小数)
  (float-vector
   (random 86)           ;; Joint 1 - 0.0 から 85.0 の範囲でランダムな整数
   (random 86)           ;; Joint 2 - 0.0 から 85.0 の範囲でランダムな整数
   (random 86)           ;; Joint 3 - 0.0 から 85.0 の範囲でランダムな整数
   (random 86)           ;; Joint 4 - 0.0 から 85.0 の範囲でランダムな整数
   (random 86)           ;; Joint 5 - 0.0 から 85.0 の範囲でランダムな整数
   (random 86)           ;; Joint 6 - 0.0 から 85.0 の範囲でランダムな整数
   (random 86)           ;; Joint 7 - 0.0 から 85.0 の範囲でランダムな整数
   (random 86)           ;; Joint 8 - 0.0 から 85.0 の範囲でランダムな整数
   (random 86)           ;; Joint 9 - 0.0 から 85.0 の範囲でランダムな整数
   (random 86)           ;; Joint 10 - 0.0 から 85.0 の範囲でランダムな整数
   (random 86)           ;; Joint 11 - 0.0 から 85.0 の範囲でランダムな整数
   (random 86)           ;; Joint 12 - 0.0 から 85.0 の範囲でランダムな整数
   (random 86)           ;; Joint 13 - 0.0 から 85.0 の範囲でランダムな整数
   (random 86)           ;; Joint 14 - 0.0 から 85.0 の範囲でランダムな整数
   (random 86)           ;; Joint 15 - 0.0 から 85.0 の範囲でランダムな整数
   (random 86)           ;; Joint 16 - 0.0 から 85.0 の範囲でランダムな整数
   (random 86)           ;; Joint 17 - 0.0 から 85.0 の範囲でランダムな整数
   (random 86)           ;; Joint 18 - 0.0 から 85.0 の範囲でランダムな整数
   ))


;; ランダムにビートごとのポーズを割り当て
(setq beat-pose-dictionary '()) ;; 空のリストで初期化

(dolist (beat-time beat-times)
  (let ((random-pose (random-pose)))  ;; 関節角度のランダム値を生成
    ;; ビート時間とポーズのペアをディクショナリに追加
    (push (cons beat-time random-pose) beat-pose-dictionary)
    (ros::ros-info "Beat Time: ~A -> Pose: ~A" beat-time random-pose)))



;; ビートカウントの初期化
(setq beat-index 0) ;; ビートカウント用変数

(defun get-time-difference (elapsed beat-list)
  "Get the time difference between the elapsed time and the nearest beat time."
  (let ((nearest-beat (find-if #'(lambda (x) (< (abs (- elapsed (car x))) 0.05))
			       beat-list)))
    (if nearest-beat
        (abs (- elapsed (car nearest-beat))))))

(defun should-nod (elapsed beat-list)
  "Check if the elapsed time is close to any beat time."
  (some #'(lambda (beat-time) (< (abs (- elapsed beat-time)) 0.05)) (mapcar #'car beat-list))) ;; 時刻がビートリストに近いか確認

;; 初期時刻を取得
(setq start-time (ros::time-now))

(do-until-key
 ;; 現在時刻を取得
 (let* ((current-time (ros::time-now))
	(elapsed-sec (- (send current-time :to-sec)  ;; 経過時間（秒）
			(send start-time :to-sec))))
   ;; 経過時間をターミナルに出力
   (ros::ros-info "Elapsed Time: ~A seconds" elapsed-sec)

   ;; ビートタイミングかチェックして動作
   (let ((beat-entry (find-if #'(lambda (x) (< (abs (- elapsed-sec (car x))) 0.05))
                              beat-pose-dictionary)))
     (when beat-entry
       (let ((pose (cdr beat-entry))
	     (time-diff (get-time-difference elapsed-sec beat-pose-dictionary)))
	 (ros::ros-info "Beat at ~A seconds: Pose ~A" (car beat-entry) pose)
	 (incf beat-index)
	 
	 ;; ポーズを送る
	 (send *jedy* :angle-vector pose)
	 
	 ;; 時刻差を使用して補間の待機時間を設定
	 (ros::ros-info "Sending angle vector with time diff: ~A" time-diff)
	 (send *ri* :angle-vector (send *jedy* :angle-vector) (* time-diff 1000.0) :default-controller 0 :min-time 0.1)

	 (ros::ros-info "Waiting for interpolation and checking state") ;; デバッグ
	 (send *ri* :state)
	 (send *jedy* :angle-vector (send *ri* :potentio-vector)))))

   ;; 終了状態
   (ros::ros-info "Waiting for key press..."))
 (return)) ;; ループを終了
