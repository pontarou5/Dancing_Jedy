import random

def generate_robot_dance(beat_times, head_ud_pose_segment, head_lr_pose_segment, left_arm_pose_segment, right_arm_pose_segment, invalid_move, music_smoothness, music_brightness):
    # Initialize variables
    pose_segments = {
        "head_ud": head_ud_pose_segment,
        "head_lr": head_lr_pose_segment,
        "left_arm": left_arm_pose_segment,
        "right_arm": right_arm_pose_segment,
    }

    # Previous poses to track invalid transitions
    prev_left_arm_index = None
    prev_right_arm_index = None

    # Output list for (beat_time, pose)
    output = []

    for i, beat_time in enumerate(beat_times):
        pose = [0.0] * 18  # Initialize all joint angles to 0.0


        # Select left_arm_pose_segment
        valid_left_arm_poses = [idx for idx, arm in enumerate(left_arm_pose_segment) if prev_left_arm_index is None or [prev_left_arm_index, idx] not in invalid_move]
        left_arm_index = random.choice(valid_left_arm_poses)
        left_arm_pose = left_arm_pose_segment[left_arm_index]
        for joint in left_arm_pose[0]:
            pose[joint[0]] = joint[1]
        prev_left_arm_index = left_arm_index

        # Select right_arm_pose_segment
        valid_right_arm_poses = [idx for idx, arm in enumerate(right_arm_pose_segment) if prev_right_arm_index is None or [prev_right_arm_index, idx] not in invalid_move]
        right_arm_index = random.choice(valid_right_arm_poses)
        right_arm_pose = right_arm_pose_segment[right_arm_index]
        for joint in right_arm_pose[0]:
            pose[joint[0]] = joint[1]
        prev_right_arm_index = right_arm_index

        # Select head_ud_pose_segment every 4 beats or reset to init_pose
        if i % 4 == 0:
            head_ud_pose = random.choice(head_ud_pose_segment)
        else:
            head_ud_pose = [[17, 0.0], 0.0, 0.0]  # Reset to init_pose
        pose[17] = head_ud_pose[0][1]

        # Select head_lr_pose_segment
        head_lr_pose = random.choice(head_lr_pose_segment)
        pose[16] = head_lr_pose[0][1]


        # Uncomment the following section to include send_time calculation
        # send_time = music_smoothness * (beat_times[i + 1] - beat_time) if i < len(beat_times) - 1 else 0
        # output.append((beat_time, pose, send_time))

        # Append beat_time and pose (without send_time)
        print(pose)
        output.append((beat_time, " ".join(map(str, pose))))

    return output

# Example input data (from the prompt)
head_ud_pose_segment = [
    [[17, 53.1563], -0.2, 0.0],
    [[17, 32.0625], -0.5, 0.0],
    [[17, 0.0], 0.0, 0.0],
    [[17, -32.0625], 0.5, 0.0],
    [[17, -53.1563], 0.9, 0.0],
]

head_lr_pose_segment = [
    [[16, -79.3463], 1.0, 1.0],
    [[16, -44.685], 0.5, 0.5],
    [[16, -24.9075], 0.3, 0.3],
    [[16, 0.0], 0.0, 0.0],
    [[16, -24.9075], 0.3, -0.3],
    [[16, -44.685], 0.5, -0.5],
    [[16, -79.3463], 1.0, -1.0],
]

left_arm_pose_segment = [
    [[[8, 126.596], [9, 5.46749], [10, 0.13499], [11, -42.8625]], 1.0, 0.5],
    [[[8, 95.2087], [9, 5.12999], [10, -0.13501], [11, -42.8625]], 0.7, 0.3],
    [[[8, 67.7025], [9, 2.90249], [10, -0.13501], [11, -24.3337]], 0.0, 0.0],
    [[[8, 30.2062], [9, 2.90249], [10, -0.13501], [11, -24.6712]], -0.5, 0.0],
    [[[8, 79.5487], [9, -5.09626], [10, 1.48499], [11, -115.087]], 0.7, 0.5],
]

right_arm_pose_segment = [
    [[[0, -126.596], [1, -5.46749], [2, -0.13499], [3, -42.8625]], 1.0, -0.5],
    [[[0, -95.2087], [1, -5.12999], [2, 0.13501], [3, -42.8625]], 0.7, -0.3],
    [[[0, -67.7025], [1, -2.90249], [2, 0.13501], [3, -24.3337]], 0.0, 0.0],
    [[[0, -30.2062], [1, -2.90249], [2, 0.13501], [3, -24.6712]], -0.5, 0.0],
    [[[0, -79.5487], [1, 5.09626], [2, -1.48499], [3, -115.087]], 0.7, -0.5],
]

invalid_move = [[3, 14], [12, 13], [13, 12], [14, 3]]
beat_times = [1.0, 2.0, 3.0, 4.0, 5.0, 6.0, 7.0, 8.0, 9.0, 10.0, 11.0, 12.0, 13.0, 14.0, 15.0, 16.0, 17.0, 18.0, 19.0, 20.0, 21.0, 22.0, 23.0, 24.0, 25.0, 26.0, 27.0, 28.0, 29.0, 30.0, 31.0, 32.0, 33.0, 34.0, 35.0, 36.0, 37.0, 38.0, 39.0, 40.0, 41.0, 42.0, 43.0, 44.0, 45.0, 46.0, 47.0, 48.0, 49.0, 50.0, 51.0, 52.0, 53.0, 54.0, 55.0, 56.0, 57.0, 58.0, 59.0, 60.0]
music_smoothness = 0.3
music_brightness = -1.0

# Generate the dance poses
dance_moves = generate_robot_dance(beat_times, head_ud_pose_segment, head_lr_pose_segment, left_arm_pose_segment, right_arm_pose_segment, invalid_move, music_smoothness, music_brightness)

# Print the output
for move in dance_moves:
    print(f"({move[0]} {move[1]})")
