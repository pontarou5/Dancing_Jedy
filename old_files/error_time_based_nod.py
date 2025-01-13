import rospy
import random
from std_msgs.msg import String
from trajectory_msgs.msg import JointTrajectory, JointTrajectoryPoint
import time

# ROSノードの初期化
rospy.init_node('jedy_dance', anonymous=True)

# ジョイント角度を制御するパブリッシャの設定
joint_trajectory_pub = rospy.Publisher('/fullbody_controller/follow_joint_trajectory', JointTrajectory, queue_size=10)

# ビートタイミングリスト
beat_times = [
    14.617, 15.360, 16.091, 16.823, 17.578, 18.321, 19.075, 19.807, 20.550, 21.281, 22.013, 22.756,
    23.510, 24.242, 24.973, 25.728, 26.471, 27.214, 27.945, 28.688, 29.431, 30.174, 30.929, 31.660,
    32.403, 33.135, 33.878, 34.621, 35.352, 36.107, 36.838, 37.593, 38.325, 39.068, 39.962, 40.542,
    41.285, 42.017, 42.771, 43.503, 44.246, 44.989, 45.732, 46.463, 47.206, 47.949, 48.692, 49.447,
    50.178, 50.921, 51.664, 52.407, 53.139, 53.870, 54.625, 55.356, 56.099, 56.842, 57.574, 58.329,
    59.060
]

# 交互するポーズをランダムに生成する関数
def alternating_pose(counter):
    pose_1 = [89.91, -3.84749, -29.9362, -99.765, -2.93624, 0.0, 0.0, 0.0, 99.8325, 4.42126, 29.835,
              -115.594, -87.615, 0.0, 0.0, 0.0, -1.005828e-05, -0.13501]
    pose_2 = [-98.7525, -4.18499, -29.5987, -101.014, -2.59874, 0.0, 0.0, 0.0, -87.615, 4.11751, 29.835,
              -100.609, -87.9187, 0.0, 0.0, 0.0, -0.30376, -0.13501]
    
    # カウンタが偶数ならpose_1、奇数ならpose_2を返す
    return pose_1 if counter % 2 == 0 else pose_2

# ビートタイミングとランダムポーズの辞書作成
beat_pose_dictionary = [(beat_time, alternating_pose(idx+1)) for idx, beat_time in enumerate(beat_times)]
beat_pose_dictionary.sort(key=lambda x: x[0])

# 開始時刻を記録
start_time = time.time()
current_beat_index = 0

# ループの設定
rate = rospy.Rate(20)

try:
    while not rospy.is_shutdown():
        elapsed_time = time.time() - start_time
        rospy.loginfo(f"Elapsed Time: {elapsed_time:.3f} seconds")

        if current_beat_index < len(beat_pose_dictionary):
            next_beat_time, pose = beat_pose_dictionary[current_beat_index]

            if elapsed_time >= next_beat_time:
                rospy.loginfo(f"Next Beat at {next_beat_time:.3f} seconds: Pose {pose}")

                # メッセージの生成と送信
                msg = JointTrajectory()
                msg.joint_names = ["rarm_joint0", "rarm_joint1", "rarm_joint2", "rarm_joint3",
               "rarm_joint4", "rarm_joint5", "rarm_joint6", "rarm_gripper_joint",
               "larm_joint0", "larm_joint1", "larm_joint2", "larm_joint3",
               "larm_joint4", "larm_joint5", "larm_joint6", "larm_gripper_joint",
               "head_joint0", "head_joint1", "front_right_wheel_joint",
               "front_left_wheel_joint", "rear_right_wheel_joint",
               "rear_left_wheel_joint"]
                point = JointTrajectoryPoint()
                point.positions = pose
                point.time_from_start = rospy.Duration(0.1)  # 適切な遷移時間を設定
                msg.points.append(point)

                joint_trajectory_pub.publish(msg)

                # インデックスを更新
                current_beat_index += 1

        rate.sleep()

except rospy.ROSInterruptException:
    rospy.loginfo("Dance interrupted.")
