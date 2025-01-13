#!/usr/bin/env roseus

(load "package://jedy_bringup/euslisp/jedy-interface.l")
(jedy-init)
(send *ri* :servo-on)
(do-until-key
   (send *jedy* :head_joint0 :joint-angle 0)
   (send *jedy* :head_joint1 :joint-angle 90)
   (send *ri* :angle-vector (send *jedy* :angle-vector) 1000)
   (send *ri* :wait-interpolation) ;; 補間がおわるのを待つ
   (send *jedy* :head_joint0 :joint-angle 0)
   (send *jedy* :head_joint1 :joint-angle 0)
   (send *ri* :angle-vector (send *jedy* :angle-vector) 1000)
   (send *ri* :wait-interpolation) ;; 補間がおわるのを待つ
   )
   (return)) ;; ループを終了