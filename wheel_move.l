#!/usr/bin/env roseus

(load "package://jedy_bringup/euslisp/jedy-interface.l")
(jedy-init)

(setq button-state 0)
(setq button-flag 0) ;; ボタンが押された回数を記録する
(ros::rate 10)

(print 1)

(while t
  (send *ri* :send-cmd-vel-raw 1 0 0) ;; ロボットを前進させる
  (setq button-state (send *ri* :state :atom-s3-button)) ;; ボタン状態を取得
  ;;(ros::ros-info (format nil "button state ~A" button-state)) ;; ログ出力
  (print 2)
  
  ;; ボタンが押されたときの処理
  (when (and (not (= button-state 0)) (= button-flag 0))
    (print 2)
    (ros::ros-info "Button pressed: reversing!") ;; ログを表示
    (send *ri* :send-cmd-vel-raw -10 0 0) ;; 後退させる
    (setq button-flag 1) ;; フラグを１に変更
    (setq button-state (send *ri* :state :atom-s3-button))) ;; ボタン状態を取得


  (when (and (= button-state 0) (= button-flag 1)) ;;フラグが1のとき
    (print 3) 
    (send *ri* :send-cmd-vel-raw -10 0 0) ;; 後退させる
    (setq button-state (send *ri* :state :atom-s3-button))) ;; ボタン状態を取得

  ;; ボタンが再び押された場合に終了
  (when (and (not (= button-state 0)) (= button-flag 1))
    (ros::ros-info "Button pressed again: stopping.") ;; ログを表示
    (send *ri* :send-cmd-vel-raw 0 0 0) ;; 動作を停止
    (return)) ;; ループを終了

  (ros::sleep)
  (send *ri* :spin-once)) ;; メッセージ処理を進める