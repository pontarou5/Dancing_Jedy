#!/usr/bin/env roseus
(require :json-decode "package://roseus_mongo/euslisp/json/json-decode.l")

(with-open-file (str "/tmp/dance_data.json" :direction :input)
  (setq parsed (json::parse-from-string (read-line str))))

(when parsed
  (print (cdr (assoc :beat_times parsed))))



; #!/usr/bin/env roseus

; ;; ROSパッケージをロード
; (ros::load-ros-manifest "std_msgs")

; ;; ノードの初期化
; (ros::roseus "audio_subscriber")

; ;; 最新のトピックデータを格納するための変数を定義
; (defparameter *current-position* 0)

; ;; std_msgs/Float64メッセージ型を利用してトピックをサブスクライブ
; (ros::subscribe "/audio/current_position" std_msgs::float64
;   #'(lambda (msg)
;       (setf *current-position* (send msg :data))))

; ;;実機とつなぐかどうか
; (setq *use-robot* t)
; ; (setq *use-robot* nil)



; ;;実機の初期設定
; (when *use-robot*
;   (load "package://jedy_bringup/euslisp/jedy-interface.l")
;   (jedy-init)

;   (send *ri* :send-stretch
; 	:names '("rarm_joint0" "rarm_joint1" "rarm_joint2" "rarm_joint3"
; 		 "rarm_joint4" "rarm_joint5" "rarm_joint6" "rarm_gripper_joint"
; 		 "larm_joint0" "larm_joint1" "larm_joint2" "larm_joint3"
; 		 "larm_joint4" "larm_joint5" "larm_joint6" "larm_gripper_joint"
; 		 "head_joint0" "head_joint1" "front_right_wheel_joint"
; 		 "front_left_wheel_joint" "rear_right_wheel_joint"
; 		 "rear_left_wheel_joint")
; 	:value '(64 64 64 64 127 127 127 127 127 127 127 127 127 127 127 127))

;   (send (send *ri* :read-stretch) :slots)

;   (send *ri* :servo-on)
;   )



; ;; ビートタイミングとポーズを定義するリスト
; (setq beat-times '(24.207 24.938 25.670 26.401 27.133 27.864 28.595 29.327 30.058 30.790 31.509 32.253 32.972 33.704 34.435 35.167 35.886 36.618 37.349 38.104 38.824 39.555 40.287 41.030 41.761 42.493 43.212 43.955 44.687 45.418 46.150 46.869 47.624 48.367 49.087 49.818 50.550 51.270 52.013 52.744 53.476 54.207 54.938 55.681 56.401 57.121 57.841 58.584 59.292)
; )

; ;; ビート時刻とポーズのペアを格納する辞書型リスト
; (setq beat-pose-dictionary '())

; ;; 規則的に4種類のポーズを当てはめる関数
; (defun alternating-pose (counter)
;   "Return an alternating pose based on the current index (counter mod 4)."
;   (let (
;         (pose-1 '(-80.19 -93.6225 -0.13499 0.13501 0.30376 0.0 0.0 0.0 -15.39 63.8888 -68.3775 -107.123 0.13501 0.0 0.0 0.0 -58.4213 -0.13501))
;         (pose-2 '(-80.19 -93.6225 -0.13499 -132.57 0.64126 0.0 0.0 0.0 -15.39 64.2263 -68.3775 -107.123 0.13501 0.0 0.0 0.0 -7.32376 -0.13501))
;         (pose-3 '(89.91 -3.84749 -29.9362 -99.765 -2.93624 0.0 0.0 0.0 
;                      99.8325 4.42126 29.835 -115.594 -87.615 0.0 0.0 0.0 
;                      -1.005828e-05 -0.13501))
;         (pose-4 '(-98.7525 -4.18499 -29.5987 -101.014 -2.59874 0.0 0.0 0.0 
;                     -7.615 4.11751 29.835 -100.609 -87.9187 0.0 0.0 0.0 
;                     -0.303762 -0.13501))
;        )
;     (case (mod counter 4)
;       (0 pose-1)
;       (1 pose-2)
;       (2 pose-3)
;       (3 pose-4))))

; ;;beat-pose-dictionaryをalternating-poseをもとに作成
; (setq *counter-pose* 0)
; ; (dolist (beat-time beat-times)
; ;     (setf *counter-pose* (+ 1 *counter-pose*))
; ;   (let ((random-pose (alternating-pose *counter-pose*)))
; ;     (push (cons beat-time random-pose) beat-pose-dictionary)))

; (setq beat-pose-dictionary 
; '(
; (24.207 -67.7025 -2.90249 0.13501 -24.3337 0.0 0.0 0.0 0.0 92.6437 56.0925 75.8025 48.2625 0.0 0.0 0.0 0.0 -44.685 -53.1563)
; (24.938 -86.9062 -15.795 49.68 -94.1625 0.0 0.0 0.0 0.0 92.9812 79.0425 -2.09251 -4.11749 0.0 0.0 0.0 0.0 -44.685 0.0)
; (25.67 -67.7025 -2.90249 0.13501 -24.3337 0.0 0.0 0.0 0.0 92.9812 78.7387 -2.39626 86.4338 0.0 0.0 0.0 0.0 79.3463 0.0)
; (26.401 -79.5487 5.09626 -1.48499 -115.087 0.0 0.0 0.0 0.0 79.5487 -5.09626 1.48499 -115.087 0.0 0.0 0.0 0.0 -24.9075 0.0)
; (27.133 -67.7025 -2.90249 0.13501 -24.3337 0.0 0.0 0.0 0.0 92.6437 56.0925 75.8025 48.2625 0.0 0.0 0.0 0.0 -44.685 -53.1563)
; (27.864 -86.9062 -15.795 49.68 -94.1625 0.0 0.0 0.0 0.0 92.9812 79.0425 -2.09251 -4.11749 0.0 0.0 0.0 0.0 -44.685 0.0)
; (28.595 -67.7025 -2.90249 0.13501 -24.3337 0.0 0.0 0.0 0.0 92.9812 78.7387 -2.39626 86.4338 0.0 0.0 0.0 0.0 79.3463 0.0)
; (29.327 -79.5487 5.09626 -1.48499 -115.087 0.0 0.0 0.0 0.0 79.5487 -5.09626 1.48499 -115.087 0.0 0.0 0.0 0.0 -24.9075 0.0)
; (30.058 -86.9062 -15.795 49.68 -94.1625 0.0 0.0 0.0 0.0 23.0175 76.5112 70.74 123.356 0.0 0.0 0.0 0.0 44.685 32.0625)
; (30.79 -92.9812 -75.87 2.39626 -50.8275 0.0 0.0 0.0 0.0 -52.6163 40.9387 75.8025 29.8013 0.0 0.0 0.0 0.0 -44.685 0.0)
; (31.509 -92.9812 -78.7387 2.39626 86.4338 0.0 0.0 0.0 0.0 37.395 16.0987 -54.2025 -93.8587 0.0 0.0 0.0 0.0 -44.685 0.0)
; (32.253 -126.596 -5.46749 -0.13499 -42.8625 0.0 0.0 0.0 0.0 92.9812 79.0425 -2.09251 -4.11749 0.0 0.0 0.0 0.0 0.0 0.0)
; (32.972 -86.9062 -15.795 49.68 -94.1625 0.0 0.0 0.0 0.0 23.0175 76.5112 70.74 123.356 0.0 0.0 0.0 0.0 44.685 32.0625)
; (33.704 -92.9812 -75.87 2.39626 -50.8275 0.0 0.0 0.0 0.0 -52.6163 40.9387 75.8025 29.8013 0.0 0.0 0.0 0.0 -44.685 0.0)
; (34.435 -92.9812 -78.7387 2.39626 86.4338 0.0 0.0 0.0 0.0 37.395 16.0987 -54.2025 -93.8587 0.0 0.0 0.0 0.0 -44.685 0.0)
; (35.167 -126.596 -5.46749 -0.13499 -42.8625 0.0 0.0 0.0 0.0 92.9812 79.0425 -2.09251 -4.11749 0.0 0.0 0.0 0.0 0.0 0.0)
; (35.886 -86.9062 -15.795 49.68 -94.1625 0.0 0.0 0.0 0.0 50.4562 -10.2263 76.1062 19.9125 0.0 0.0 0.0 0.0 79.3463 53.1563)
; (36.618 -86.9062 -15.795 49.68 -94.1625 0.0 0.0 0.0 0.0 30.2062 2.90249 -0.13501 -24.6712 0.0 0.0 0.0 0.0 44.685 0.0)
; (37.349 -92.9812 -79.0425 2.09251 -4.11749 0.0 0.0 0.0 0.0 86.9062 15.795 -49.68 -94.1625 0.0 0.0 0.0 0.0 79.3463 0.0)
; (38.104 -30.2062 -2.90249 0.13501 -24.6712 0.0 0.0 0.0 0.0 -52.6163 40.9387 75.8025 29.8013 0.0 0.0 0.0 0.0 -24.9075 0.0)
; (38.824 -86.9062 -15.795 49.68 -94.1625 0.0 0.0 0.0 0.0 50.4562 -10.2263 76.1062 19.9125 0.0 0.0 0.0 0.0 79.3463 53.1563)
; (39.555 -86.9062 -15.795 49.68 -94.1625 0.0 0.0 0.0 0.0 30.2062 2.90249 -0.13501 -24.6712 0.0 0.0 0.0 0.0 44.685 0.0)
; (40.287 -92.9812 -79.0425 2.09251 -4.11749 0.0 0.0 0.0 0.0 86.9062 15.795 -49.68 -94.1625 0.0 0.0 0.0 0.0 79.3463 0.0)
; (41.03 -30.2062 -2.90249 0.13501 -24.6712 0.0 0.0 0.0 0.0 -52.6163 40.9387 75.8025 29.8013 0.0 0.0 0.0 0.0 -24.9075 0.0)
; (41.761 -80.19 -93.9262 -1.48499 -115.087 0.0 0.0 0.0 0.0 92.9812 78.7387 -2.39626 86.4338 0.0 0.0 0.0 0.0 -44.685 53.1563)
; (42.493 -86.9062 -15.795 49.68 -94.1625 0.0 0.0 0.0 0.0 92.6437 56.0925 75.8025 48.2625 0.0 0.0 0.0 0.0 -24.9075 0.0)
; (43.212 -67.7025 -2.90249 0.13501 -24.3337 0.0 0.0 0.0 0.0 92.6437 56.0925 75.8025 48.2625 0.0 0.0 0.0 0.0 -79.3463 0.0)
; (43.955 -53.73 5.09626 -76.4437 21.2288 0.0 0.0 0.0 0.0 92.9812 78.7387 -2.39626 86.4338 0.0 0.0 0.0 0.0 24.9075 0.0)
; (44.687 -80.19 -93.9262 -1.48499 -115.087 0.0 0.0 0.0 0.0 92.9812 78.7387 -2.39626 86.4338 0.0 0.0 0.0 0.0 -44.685 53.1563)
; (45.418 -86.9062 -15.795 49.68 -94.1625 0.0 0.0 0.0 0.0 92.6437 56.0925 75.8025 48.2625 0.0 0.0 0.0 0.0 -24.9075 0.0)
; (46.15 -67.7025 -2.90249 0.13501 -24.3337 0.0 0.0 0.0 0.0 92.6437 56.0925 75.8025 48.2625 0.0 0.0 0.0 0.0 -79.3463 0.0)
; (46.869 -53.73 5.09626 -76.4437 21.2288 0.0 0.0 0.0 0.0 92.9812 78.7387 -2.39626 86.4338 0.0 0.0 0.0 0.0 24.9075 0.0)
; (47.624 -79.5487 5.09626 -1.48499 -115.087 0.0 0.0 0.0 0.0 92.9812 78.7387 -2.39626 86.4338 0.0 0.0 0.0 0.0 24.9075 0.0)
; (48.367 -92.6437 -56.0925 -75.8025 48.2625 0.0 0.0 0.0 0.0 67.7025 2.90249 -0.13501 -24.3337 0.0 0.0 0.0 0.0 -44.685 0.0)
; (49.087 -92.9812 -78.7387 2.39626 86.4338 0.0 0.0 0.0 0.0 37.395 16.0987 -54.2025 -93.8587 0.0 0.0 0.0 0.0 24.9075 0.0)
; (49.818 -95.2087 -5.12999 0.13501 -42.8625 0.0 0.0 0.0 0.0 126.596 5.46749 0.13499 -42.8625 0.0 0.0 0.0 0.0 24.9075 0.0)
; (50.55 -79.5487 5.09626 -1.48499 -115.087 0.0 0.0 0.0 0.0 92.9812 78.7387 -2.39626 86.4338 0.0 0.0 0.0 0.0 24.9075 0.0)
; (51.27 -92.6437 -56.0925 -75.8025 48.2625 0.0 0.0 0.0 0.0 67.7025 2.90249 -0.13501 -24.3337 0.0 0.0 0.0 0.0 -44.685 0.0)
; (52.013 -92.9812 -78.7387 2.39626 86.4338 0.0 0.0 0.0 0.0 37.395 16.0987 -54.2025 -93.8587 0.0 0.0 0.0 0.0 24.9075 0.0)
; (52.744 -95.2087 -5.12999 0.13501 -42.8625 0.0 0.0 0.0 0.0 126.596 5.46749 0.13499 -42.8625 0.0 0.0 0.0 0.0 24.9075 0.0)
; (53.476 -92.9812 -78.7387 2.39626 86.4338 0.0 0.0 0.0 0.0 79.5487 -5.09626 1.48499 -115.087 0.0 0.0 0.0 0.0 24.9075 32.0625)
; (54.207 52.6163 -40.9387 -75.8025 29.8013 0.0 0.0 0.0 0.0 -52.6163 40.9387 75.8025 29.8013 0.0 0.0 0.0 0.0 -79.3463 0.0)
; (54.938 -23.0175 -76.5112 -70.74 123.356 0.0 0.0 0.0 0.0 95.2087 5.12999 -0.13501 -42.8625 0.0 0.0 0.0 0.0 -24.9075 0.0)
; (55.681 52.6163 -40.9387 -75.8025 29.8013 0.0 0.0 0.0 0.0 67.7025 2.90249 -0.13501 -24.3337 0.0 0.0 0.0 0.0 -44.685 0.0)
; (56.401 -92.9812 -78.7387 2.39626 86.4338 0.0 0.0 0.0 0.0 79.5487 -5.09626 1.48499 -115.087 0.0 0.0 0.0 0.0 24.9075 32.0625)
; (57.121 52.6163 -40.9387 -75.8025 29.8013 0.0 0.0 0.0 0.0 -52.6163 40.9387 75.8025 29.8013 0.0 0.0 0.0 0.0 -79.3463 0.0)
; (57.841 -23.0175 -76.5112 -70.74 123.356 0.0 0.0 0.0 0.0 95.2087 5.12999 -0.13501 -42.8625 0.0 0.0 0.0 0.0 -24.9075 0.0)
; (58.584 52.6163 -40.9387 -75.8025 29.8013 0.0 0.0 0.0 0.0 67.7025 2.90249 -0.13501 -24.3337 0.0 0.0 0.0 0.0 -44.685 0.0)
; (59.292 -30.2062 -2.90249 0.13501 -24.6712 0.0 0.0 0.0 0.0 30.2062 2.90249 -0.13501 -24.6712 0.0 0.0 0.0 0.0 -79.3463 53.1563)
; ))

; (setq beat-pose-dictionary (sort beat-pose-dictionary `(lambda (a b) (< (car a) (car b)))))
; (ros::ros-info "~A" beat-pose-dictionary)


; (defun set-current-index (current-position beat-times)
;   ; (ros::ros-info "run function : set-current-index")
;   (let ((current-index 0))
;     (dolist (beat-time beat-times)
;       (unless (numberp beat-time)
;         (ros::ros-info "beat-time is ~A so it is invalid" beat-time)
;         (return-from set-current-index nil))
;       (when (> beat-time current-position)
;         ; (ros::ros-info "current-index: ~A | current-beat: ~A" current-index beat-time)
;         ; ;; 戻り値の型をログに明示
;         ; (ros::ros-info "Returning: ~A" (list current-index beat-time))
;         (return-from set-current-index (list current-index beat-time))
;       )
;       (incf current-index))
;     nil))

; (defun get-next-info (current-position beat-pose-dictionary current-index current-beat)
;   "Returns the information for the next beat if the current position is close to the current beat."
;   (let* ((current-beat-and-pose (nth current-index beat-pose-dictionary)) ;; 現在のビート情報
;          (tolerance 0.1)) ;; 許容誤差（例: 100ms）
    
;     ; ; 変数の状態を出力
;     ; (format t "DEBUG: current-position=~A, current-beat=~A, current-index=~A~%"
;     ;         current-position current-beat current-index)
    
;     ;; 近いビートがあるかどうかを確認
;     (if (or (<= (abs (- current-position current-beat)) tolerance) ;; 最初のビートも許容
;             (= current-index 0))                                 ;; 最初のビートを強制的に処理
;         (progn
;           (format t "DEBUG: Close enough or first beat - checking next beat~%")
;           ; (let ((next-index (1+ current-index))) ;; 次のインデックスを計算
;           (let ((next-index (+ 1 current-index))) ;; 次のインデックスを計算

;             ;; 次のインデックスが範囲内か確認
;             (if (< next-index (length beat-pose-dictionary))
;                 (let* ((next-beat-and-pose (nth next-index beat-pose-dictionary)) ;; 次のビート情報
;                        (next-time (car next-beat-and-pose))                        ;; 次のビート時刻
;                        (next-pose (cdr next-beat-and-pose)))                       ;; 次のビートのポーズ
;                   ;; 結果を計算して返す
;                   (format t "DEBUG: Found next beat at index ~A: next-time=~A, next-pose=~A~%"
;                           next-index next-time next-pose)
;                   (list (* 0.9 (- next-time current-position)) next-time next-pose next-index))
;                 ;; 次のインデックスが範囲外の場合のログ
;                 (progn
;                   ; (format t "DEBUG: Next index (~A) is out of range~%" next-index)
;                   (return-from get-next-info nil)))))

;       ;; 近いビートがない場合のログ
;       ; (format t "DEBUG: No beat is close enough: current-position=~A, current-beat=~A~%"
;       ;         current-position current-beat)
;       (return-from get-next-info nil))))

                                         
        
; ;; 直後のビートのインデックスを保持
; (setq current-index 0)

; ;; 実行部分、進行状況をインデックスで管理
; (ros::rate 30)

; (do-until-key

;   (ros::spin-once)  ;; コールバックを処理
;   (if *current-position*  ;;この条件が満たされた時のみ以下全体の処理を行う
;     (progn
;       ; (format t "*current-position*: ~A seconds~%" *current-position*)
;       ; (ros::ros-info "got valid current-position")    
;       (let* ((current-index-and-beat  (set-current-index *current-position* beat-times))
;             (current-index  (car current-index-and-beat))
;             (current-beat (first (cdr current-index-and-beat))))
;         ; (ros::ros-info "current-index: ~A" current-index)

;         ;;次のビートの情報を取得
;         (setq next-info-list (get-next-info *current-position* beat-pose-dictionary current-index current-beat))
;         (if next-info-list
;             (let ((time-diff (nth 0 next-info-list))
;                   (next-beat (nth 1 next-info-list))
;                   (pose (remove-if #'null (nth 2 next-info-list)));; なぜか含まれるnilを取り除く
;                   (next-index (nth 3 next-info-list)))  ;; 新しいインデックス

;               ; (ros::ros-info "*current-position*: ~A seconds" *current-position*)

;               ; 次のビートの情報とポーズを送信
;               (ros::ros-info "next-index: ~A | next-beat: ~A | seconds pose:~A " next-index next-beat pose)
;               (ros::ros-info "time-diff: ~A" time-diff)
;               (when *use-robot* (send *jedy* :angle-vector pose))

;               ;; 時刻差に応じて補間(* 1000 time-diff)、wait-interpolation
;               (when *use-robot*
;                 ; (ros::ros-info "before-move: ~A seconds" (- (send (ros::time-now) :to-sec) (send start-time :to-sec)))
;                 (send *ri* :angle-vector (send *jedy* :angle-vector) time-diff :default-controller 0 :min-time 0.1)
;                 ;; (ros::ros-info "after-move: ~A seconds" (- (send (ros::time-now) :to-sec) (send start-time :to-sec)))
;                 (send *ri* :wait-interpolation)
;                 ;; (ros::ros-info "after-wait: ~A seconds" (- (send (ros::time-now) :to-sec) (send start-time :to-sec)))
;               )
    
;                 ; 終了待機状態
;               (ros::ros-info "Waiting for key press...")
;             )
;             (progn
;               (ros::ros-info "get *current-position* sucssesfully but not found beat within 0.05 s")
;               (ros::ros-info "*current-position* :~A seconds" *current-position*)
;             )
;         )
;       )
;     )
;     (ros::ros-info "not found *current-position*")
;   )
;   (ros::sleep)
; )

; ;; プログラムの終了を防ぐためにループを維持
; (ros::rate 10 (do-until-key
;                  (ros::spin-once)))