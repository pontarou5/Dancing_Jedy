import random
import json

def generate_robot_dance_fixed_pattern(beat_times, head_ud_pose_segment, head_lr_pose_segment, left_arm_pose_segment, right_arm_pose_segment, invalid_move):
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
    prev_4pose = [[],[],[],[]]

    for i, beat_time in enumerate(beat_times):
        pose = [0.0] * 18  # Initialize all joint angles to 0.0



        # Determine which pose in the fixed sequence to use (cyclic)
        seq_index = i % 8

        if (seq_index == 0 or seq_index == 1 or seq_index == 2 or seq_index == 3) :


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



            # Append beat_time and pose
            print(pose)
            prev_4pose[seq_index] = pose
        
        else: #(seq_index == 4 or seq_index == 5 or seq_index == 6 or seq_index == 7)
            mod_4_index = seq_index % 4
            pose = prev_4pose[mod_4_index]
            output.append((beat_time, " ".join(map(str, pose))))


    return output

# Example input data (same as before)
head_ud_pose_segment = [
    [[17, 53.1563], -0.2, 0.0],
    [[17, 32.0625], -0.5, 0.0],
    [[17, 0.0], 0.0, 0.0],
    [[17, -32.0625], 0.5, 0.0],
    [[17, -53.1563], 0.9, 0.0],
]

head_lr_pose_segment = [
    [[16, 79.3463], 1.0, 1.0],
    [[16, 44.685], 0.5, 0.5],
    [[16, 24.9075], 0.3, 0.3],
    [[16, 0.0], 0.0, 0.0],
    [[16, -24.9075], 0.3, -0.3],
    [[16, -44.685], 0.5, -0.5],
    [[16, -79.3463], 1.0, -1.0],
]
left_arm_pose_segment = [
    [[[8, 126.596], [9, 5.46749], [10, 0.13499], [11, -42.8625]], 1.0, 0.5],  # ばんざい
    [[[8, 95.2087], [9, 5.12999], [10, -0.13501], [11, -42.8625]], 0.7, 0.3],
    [[[8, 67.7025], [9, 2.90249], [10, -0.13501], [11, -24.3337]], 0.0, 0.0],
    [[[8, 30.2062], [9, 2.90249], [10, -0.13501], [11, -24.6712]], -0.5, 0.0],
    [[[8, 79.5487], [9, -5.09626], [10, 1.48499], [11, -115.087]], 0.7, 0.5],
    [[[8, 80.19], [9, 93.9262], [10, 1.48499], [11, -115.087]], 0.8, 0.5],
    [[[8, 86.9062], [9, 15.795], [10, -49.68], [11, -94.1625]], 0.3, 0.3],
    [[[8, 37.395], [9, 16.0987], [10, -54.2025], [11, -93.8587]], 0.2, 0.0],
    [[[8, 92.9812], [9, 75.87], [10, -2.39626], [11, -50.8275]], 1.0, 0.5],
    [[[8, 92.9812], [9, 79.0425], [10, -2.09251], [11, -4.11749]], 1.0, 0.5],
    [[[8, 92.9812], [9, 78.7387], [10, -2.39626], [11, 86.4338]], -0.2, 0.0],
    [[[8, 92.6437], [9, 56.0925], [10, 75.8025], [11, 48.2625]], 0.0, 0.1],
    [[[8, -52.6163], [9, 40.9387], [10, 75.8025], [11, 29.8013]], -0.0, 0.0],
    [[[8, 50.4562], [9, -10.2263], [10, 76.1062], [11, 19.9125]], -0.8, 0.0],
    [[[8, 23.0175], [9, 76.5112], [10, 70.74], [11, 123.356]], 1.0, 0.0],
]


right_arm_pose_segment = [
    # 0 pass
    [[[0, -126.596], [1, -5.46749], [2, -0.13499], [3, -42.8625]], 1.0, -0.5],  # ばんざい
    # 1 pass
    [[[0, -95.2087], [1, -5.12999], [2, 0.13501], [3, -42.8625]], 0.7, -0.3],
    # 2 pass
    [[[0, -67.7025], [1, -2.90249], [2, 0.13501], [3, -24.3337]], 0.0, 0.0],
    # 3 pass
    [[[0, -30.2062], [1, -2.90249], [2, 0.13501], [3, -24.6712]], -0.5, 0.0],
    # 4 pass
    [[[0, -79.5487], [1, 5.09626], [2, -1.48499], [3, -115.087]], 0.7, -0.5],
    # 5 pass
    [[[0, -80.19], [1, -93.9262], [2, -1.48499], [3, -115.087]], 0.8, -0.5],
    # 6 pass
    [[[0, -86.9062], [1, -15.795], [2, 49.68], [3, -94.1625]], 0.3, -0.3],
    # 7 pass
    [[[0, -37.395], [1, -16.0987], [2, 54.2025], [3, -93.8587]], 0.2, 0.0],
    # 8 pass
    [[[0, -92.9812], [1, -75.87], [2, 2.39626], [3, -50.8275]], 1.0, -0.5],
    # 9 pass
    [[[0, -92.9812], [1, -79.0425], [2, 2.09251], [3, -4.11749]], 1.0, -0.5],
    # 10
    [[[0, -92.9812], [1, -78.7387], [2, 2.39626], [3, 86.4338]], -0.2, 0.0],
    # 11 pass
    [[[0, -92.6437], [1, -56.0925], [2, -75.8025], [3, 48.2625]], 0.0, -0.1],
    # 12
    [[[0, 52.6163], [1, -40.9387], [2, -75.8025], [3, 29.8013]], -0.2, 0.0],
    # 13
    [[[0, -53.73], [1, 5.09626], [2, -76.4437], [3, 21.2288]], -0.8, 0.0],
    # 14
    [[[0, -23.0175], [1, -76.5112], [2, -70.74], [3, 123.356]], 1.0, 0.0],
]

invalid_move = [[3, 14], [12, 13], [13, 12], [14, 3]]
beat_times = [24.207, 24.938, 25.670, 26.401, 27.133, 27.864, 28.595, 29.327, 30.058, 30.790, 31.509, 32.253, 32.972, 33.704, 34.435, 35.167, 35.886, 36.618, 37.349, 38.104, 38.824, 39.555, 40.287, 41.030, 41.761, 42.493, 43.212, 43.955, 44.687, 45.418, 46.150, 46.869, 47.624, 48.367, 49.087, 49.818, 50.550, 51.270, 52.013, 52.744, 53.476, 54.207, 54.938, 55.681, 56.401, 57.121, 57.841, 58.584, 59.292]

# Generate the dance poses
dance_moves = generate_robot_dance_fixed_pattern(beat_times, head_ud_pose_segment, head_lr_pose_segment, left_arm_pose_segment, right_arm_pose_segment, invalid_move)

print(dance_moves)

wheel_dance_moves = ""
wheel_beat_times = ""


# 出力先のLispファイルの名前
lisp_file_path = "/tmp/data.l"

with open(lisp_file_path, 'w') as f:
    f.write("(defparameter *beat-times* '(")
    f.write(" ".join(map(str, beat_times)))
    f.write("))\n\n")

    f.write("(defparameter *dance-moves* '(\n")
    for move in dance_moves:
        time = move[0]
        pose = move[1]
        f.write(f"  ({time} {' '.join(map(str, pose))})\n")
    f.write("))\n")

