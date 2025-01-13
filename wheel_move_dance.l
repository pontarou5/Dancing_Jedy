#!/usr/bin/env roseus

(require :json-decode "package://roseus_mongo/euslisp/json/json-decode.l")

(with-open-file (str "/tmp/dance_data.json" :direction :input)
  (setq parsed (json::parse-from-string (read-line str))))

(when parsed
  (setq beat-times (cdr (assoc :wheel_beat_times parsed)))
  (setq beat-times (cdr (assoc :wheel_moves parsed)))
)

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



;; ビートタイミングとポーズを定義するリスト
(setq beat-times '(24.207 24.938 25.670 26.401 27.133 27.864 28.595 29.327 30.058 30.790 31.509 32.253 32.972 33.704 34.435 35.167 35.886 36.618 37.349 38.104 38.824 39.555 40.287 41.030 41.761 42.493 43.212 43.955 44.687 45.418 46.150 46.869 47.624 48.367 49.087 49.818 50.550 51.270 52.013 52.744 53.476 54.207 54.938 55.681 56.401 57.121 57.841 58.584 59.292)
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
        (move-foward '(2 0 0))
        (move-backward '(-2 0 0))
        (rotate-right '(0 0 10))
        (rotate-left '(0 0 -10))
        (move-right '(0 2 0))
        (move-left '(0 -2 0))
       )
    (case (mod counter 4)
      ; (0 move-foward)
      ; (1 move-backward)
      ; (2 rotate-right)
      ; (3 rotate-left)
      (0 move-right)
      (1 move-left)
      (2 move-right)
      (3 move-left)
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