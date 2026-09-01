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

(send *ri* :angle-vector #f(0.0 0.0 0.0 0.0 0.0 0.0 0.0 0.0 0.0 0.0 0.0 0.0 0.0 0.0 0.0 0.0 0.0 0.0) 500 :default-controller 0 :min-time 0.5)
(send *ri* :wait-interpolation)
(send *ri* :angle-vector #f(0.0 0.0 0.0 0.0 0.0 0.0 0.0 0.0 0.0 0.0 0.0 0.0 0.0 0.0 0.0 0.0 0.0 0.0) 500 :default-controller 0 :min-time 0.5)
(send *ri* :wait-interpolation)
(send *ri* :angle-vector #f(89.91 -3.84749 -29.9362 -99.765 -2.93624 0.0 0.0 0.0 99.8325 4.42126 29.835 -115.594 -87.615 0.0 0.0 0.0 -1.005828e-05 -0.13501) 500 :default-controller 0 :min-time 0.5)
(send *ri* :wait-interpolation)
(send *ri* :angle-vector #f(-98.7525 -4.18499 -29.5987 -101.014 -2.59874 0.0 0.0 0.0 -87.615 4.11751 29.835 -100.609 -87.9187 0.0 0.0 0.0 -0.30376 -0.13501) 500 :default-controller 0 :min-time 0.1)
(send *ri* :wait-interpolation)
(send *ri* :angle-vector #f(0.0 0.0 0.0 0.0 0.0 0.0 0.0 0.0 0.0 0.0 0.0 0.0 0.0 0.0 0.0 0.0 0.0 0.0) 500 :default-controller 0 :min-time 0.5)
(send *ri* :wait-interpolation)
(send *ri* :angle-vector #f(89.91 -3.84749 -29.9362 -99.765 -2.93624 0.0 0.0 0.0 99.8325 4.42126 29.835 -115.594 -87.615 0.0 0.0 0.0 -1.005828e-05 -0.13501) 500 :default-controller 0 :min-time 0.5)
(send *ri* :wait-interpolation)
(send *ri* :angle-vector #f(-98.7525 -4.18499 -29.5987 -101.014 -2.59874 0.0 0.0 0.0 -87.615 4.11751 29.835 -100.609 -87.9187 0.0 0.0 0.0 -0.30376 -0.13501) 500 :default-controller 0 :min-time 0.1)
(send *ri* :wait-interpolation)
