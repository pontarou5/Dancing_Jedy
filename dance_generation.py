# input: data_{music title}.py in analyzed_music_data directory including beat times, smoothness score, and brightness score of the musics
# output: add pose time series to data_{music title}.py in analyzed_music_data directory
#
# usage:
#   python3 dance_generation.py -f "オリジナル音源(mp3形式)の相対パス"

import argparse
import importlib
import os
import random
import re
import sys

SCRIPT_DIR = os.path.dirname(os.path.abspath(__file__))
DATA_DIR = os.path.join(SCRIPT_DIR, "analyzed_music_data")
sys.path.insert(0, SCRIPT_DIR)


def remove_elements_by_indices(input_list, indices_to_remove):
    # インデックスを降順にソートし、リストから削除
    for index in sorted(indices_to_remove, reverse=True):
        if index < len(input_list):  # 範囲内のインデックスの場合に削除
            del input_list[index]
    return input_list


# トリム済み(rarm4関節+larm4関節+head2関節)のポーズに変換する
# pose は [rarm0..3(index0-3), rarm4-7(未使用,index4-7), larm0..3(index8-11),
#          larm4-7(未使用,index12-15), head_lr(index16), head_ud(index17)] の18要素
def _trim_pose(pose):
    return pose[0:4] + pose[8:12] + [pose[16], pose[17]]


def generate_robot_dance_fixed_pattern(raw_beat_times, head_ud_pose_segment, head_lr_pose_segment,
                                        left_arm_pose_segment, right_arm_pose_segment, invalid_move,
                                        brightness, smoothness):

    max_dropout_number = 0
    if smoothness < 0.5:
        max_dropout_number = 2
    elif smoothness < 0.7:
        max_dropout_number = 3
    else:
        max_dropout_number = 4

    cycle_head_move_beat = 0
    if brightness < 0.0:
        cycle_head_move_beat = 8
    else:
        cycle_head_move_beat = 4

    # Initialize variables
    prev_left_arm_index = None
    prev_right_arm_index = None
    output = []
    random_removed_output = []
    adding_beat_times = []
    prev_4pose = [[], [], [], []]

    for i, beat_time in enumerate(raw_beat_times):
        pose = [0.0] * 18  # Initialize all joint angles to 0.0
        seq_index = i % 8

        if seq_index in [0, 1, 2, 3]:  # Original poses
            # Select left arm pose
            valid_left_arm_poses = [idx for idx in range(len(left_arm_pose_segment))
                                    if prev_left_arm_index is None or [prev_left_arm_index, idx] not in invalid_move]
            left_arm_index = random.choice(valid_left_arm_poses)
            left_arm_pose = left_arm_pose_segment[left_arm_index]
            for joint in left_arm_pose[0]:
                pose[joint[0]] = joint[1]
            prev_left_arm_index = left_arm_index

            # Select right arm pose
            valid_right_arm_poses = [idx for idx in range(len(right_arm_pose_segment))
                                     if prev_right_arm_index is None or [prev_right_arm_index, idx] not in invalid_move]
            right_arm_index = random.choice(valid_right_arm_poses)
            right_arm_pose = right_arm_pose_segment[right_arm_index]
            for joint in right_arm_pose[0]:
                pose[joint[0]] = joint[1]
            prev_right_arm_index = right_arm_index

            # Select head_ud pose
            move_head_index_1 = random.randint(0, cycle_head_move_beat - 1)
            if i % cycle_head_move_beat == move_head_index_1:
                head_ud_pose = random.choice(head_ud_pose_segment)
            else:
                if brightness > 0.0:
                    head_ud_pose = [[17, 0.0], 0.0, 0.0]  # Reset to init_pose
                else:
                    head_ud_pose = [[17, 16.0625], -0.3, 0.0]  # Reset to dark init_pose
            pose[17] = head_ud_pose[0][1]

            # Select head_lr pose
            move_head_index_2 = random.randint(0, cycle_head_move_beat - 1)
            if i % cycle_head_move_beat == move_head_index_2:
                head_lr_pose = random.choice(head_lr_pose_segment)
            else:
                head_lr_pose = [[16, 0.0], 0.0, 0.0]  # Reset to init_pose
            pose[16] = head_lr_pose[0][1]

            # Save pose for reuse
            prev_4pose[seq_index] = pose[:]

        else:  # Reuse previous poses
            mod_4_index = seq_index % 4
            pose = prev_4pose[mod_4_index]

        # Append beat time and (トリム済みの)pose as a list
        output.append([beat_time] + _trim_pose(pose))
        adding_beat_times.append(beat_time)
        if seq_index == 7:
            beat_and_pose_0to3 = output[-8:-4]
            beat_and_pose_4to7 = output[-4:]
            beat_0to3 = adding_beat_times[-8:-4]
            beat_4to7 = adding_beat_times[-4:]

            # ここで引き抜くビートのインデックスを0から3の中から最大max_dropout_number個決める
            dropout_number = random.randint(0, max_dropout_number)
            indices_to_remove = random.sample([0, 1, 2, 3], dropout_number)

            result_pose_0to3 = remove_elements_by_indices(beat_and_pose_0to3, indices_to_remove)
            result_pose_4to7 = remove_elements_by_indices(beat_and_pose_4to7, indices_to_remove)
            result_beat_0to3 = remove_elements_by_indices(beat_0to3, indices_to_remove)
            result_beat_4to7 = remove_elements_by_indices(beat_4to7, indices_to_remove)

            random_removed_output = output[:-8] + result_pose_0to3 + result_pose_4to7

    # 8ビート未満で終わる末尾（最後の周期の途中）は間引かずそのまま採用する
    remainder = len(raw_beat_times) % 8
    if remainder:
        random_removed_output = random_removed_output + output[-remainder:]

    return random_removed_output


# --- ポーズの候補 ---------------------------------------------------------
head_ud_pose_segment = [
    [[17, 53.1563], -0.2, 0.0],
    [[17, 32.0625], -0.5, 0.0],
    [[17, 16.0625], -0.3, 0.0],
    [[17, 0.0], 0.0, 0.0],
    [[17, 0.0], 0.0, 0.0],
    [[17, -16.0625], 0.5, 0.0],
    [[17, -32.0625], 0.9, 0.0],
    # [[17, -53.1563], 0.9, 0.0],
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
    [[[0, -126.596], [1, -5.46749], [2, -0.13499], [3, -42.8625]], 1.0, -0.5],  # ばんざい
    [[[0, -95.2087], [1, -5.12999], [2, 0.13501], [3, -42.8625]], 0.7, -0.3],
    [[[0, -67.7025], [1, -2.90249], [2, 0.13501], [3, -24.3337]], 0.0, 0.0],
    [[[0, -30.2062], [1, -2.90249], [2, 0.13501], [3, -24.6712]], -0.5, 0.0],
    [[[0, -79.5487], [1, 5.09626], [2, -1.48499], [3, -115.087]], 0.7, -0.5],
    [[[0, -80.19], [1, -93.9262], [2, -1.48499], [3, -115.087]], 0.8, -0.5],
    [[[0, -86.9062], [1, -15.795], [2, 49.68], [3, -94.1625]], 0.3, -0.3],
    [[[0, -37.395], [1, -16.0987], [2, 54.2025], [3, -93.8587]], 0.2, 0.0],
    [[[0, -92.9812], [1, -75.87], [2, 2.39626], [3, -50.8275]], 1.0, -0.5],
    [[[0, -92.9812], [1, -79.0425], [2, 2.09251], [3, -4.11749]], 1.0, -0.5],
    [[[0, -92.9812], [1, -78.7387], [2, 2.39626], [3, 86.4338]], -0.2, 0.0],
    [[[0, -92.6437], [1, -56.0925], [2, -75.8025], [3, 48.2625]], 0.0, -0.1],
    [[[0, 52.6163], [1, -40.9387], [2, -75.8025], [3, 29.8013]], -0.2, 0.0],
    [[[0, -53.73], [1, 5.09626], [2, -76.4437], [3, 21.2288]], -0.8, 0.0],
    [[[0, -23.0175], [1, -76.5112], [2, -70.74], [3, 123.356]], 1.0, 0.0],
]

invalid_move = [[3, 14], [12, 13], [13, 12], [14, 3]]


def _format_beat_pose_dictionary(rows):
    lines = ["beat_pose_dictionary = ["]
    for row in rows:
        lines.append("    [" + ", ".join(repr(v) for v in row) + "],")
    lines.append("]")
    return "\n".join(lines) + "\n"


def write_beat_pose_dictionary(data_path, rows):
    text = open(data_path, encoding="utf-8").read()
    block = _format_beat_pose_dictionary(rows)

    pattern = re.compile(r"beat_pose_dictionary\s*=\s*\[.*?\]\n", re.S)
    if pattern.search(text):
        text = pattern.sub(block, text, count=1)
    else:
        if not text.endswith("\n"):
            text += "\n"
        text += block

    with open(data_path, "w", encoding="utf-8") as f:
        f.write(text)


def main():
    parser = argparse.ArgumentParser(description="ビートに合わせたポーズ振り付け(beat_pose_dictionary)を生成する")
    parser.add_argument("-f", "--file", required=True, help="オリジナル音源(mp3形式)の相対パス")
    args = parser.parse_args()

    song_name = os.path.splitext(os.path.basename(args.file))[0]
    data_path = os.path.join(DATA_DIR, f"data_{song_name}.py")

    if not os.path.exists(data_path):
        print(f"Error: {data_path} が見つかりません。先に音楽解析を行って beat_times/smoothness/brightness を用意してください。")
        sys.exit(1)

    module = importlib.import_module(f"analyzed_music_data.data_{song_name}")

    for attr in ("beat_times", "smoothness", "brightness"):
        if not hasattr(module, attr):
            print(f"Error: {data_path} に {attr} がありません。先に音楽解析を行ってください。")
            sys.exit(1)

    if hasattr(module, "beat_pose_dictionary"):
        answer = input(
            f"{song_name} には既に beat_pose_dictionary が存在します。振り付けを再生成しますか？ [y/N]: "
        )
        if answer.strip().lower() not in ("y", "yes"):
            print("中止しました。")
            return

    beat_pose_dictionary = generate_robot_dance_fixed_pattern(
        module.beat_times, head_ud_pose_segment, head_lr_pose_segment,
        left_arm_pose_segment, right_arm_pose_segment, invalid_move,
        module.brightness, module.smoothness,
    )
    write_beat_pose_dictionary(data_path, beat_pose_dictionary)
    print(f"{data_path} に beat_pose_dictionary ({len(beat_pose_dictionary)} 件) を書き込みました。")


if __name__ == "__main__":
    main()
