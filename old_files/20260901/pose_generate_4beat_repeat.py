import random
import json
import sys
import os
import importlib

# コマンドライン引数でファイルを選択
if len(sys.argv) > 1:
    data_file = sys.argv[1]  # 引数で指定されたファイル名

    module_name = f"data_{data_file}"  # 拡張子 .py は不要
    try:
        data = importlib.import_module(module_name)
    except ModuleNotFoundError:
        raise ValueError(f"Unknown data file: {data_file}")

    raw_beat_times = data.beat_times
    smoothness = data.smoothness
    brightness = data.brightness
    print("Using data from:", module_name)



def old_generate_robot_dance_fixed_pattern(raw_beat_times, head_ud_pose_segment, head_lr_pose_segment, left_arm_pose_segment, right_arm_pose_segment, invalid_move):
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

    for i, beat_time in enumerate(raw_beat_times):
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
            # print(pose)
            prev_4pose[seq_index] = pose
            output.append((beat_time, " ".join(map(str, pose))))
        
        else: #(seq_index == 4 or seq_index == 5 or seq_index == 6 or seq_index == 7)
            mod_4_index = seq_index % 4
            print(mod_4_index)
            pose = prev_4pose[mod_4_index]
            output.append((beat_time, " ".join(map(str, pose))))


    return output

def remove_elements_by_indices(input_list, indices_to_remove):
    # インデックスを降順にソートし、リストから削除
    for index in sorted(indices_to_remove, reverse=True):
        if index < len(input_list):  # 範囲内のインデックスの場合に削除
            del input_list[index]
    return input_list

def generate_robot_dance_fixed_pattern(raw_beat_times, head_ud_pose_segment, head_lr_pose_segment, left_arm_pose_segment, right_arm_pose_segment, invalid_move, brightness, smoothness):
    
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
    random_removed_beat_times = []
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

        # Append beat time and pose as a list
        output.append([beat_time] + pose)
        adding_beat_times.append(beat_time)
        if seq_index == 7:
            beat_and_pose_0to3 = output[-8:-4]
            beat_and_pose_4to7 = output[-4:]
            beat_0to3 = adding_beat_times[-8:-4]
            beat_4to7 = adding_beat_times[-4:]
            # print(beat_and_pose_0to3)
            # print(beat_and_pose_4to7)

            # ここで引き抜くビートのインデックスを0から3の中から最大max_dropout_number個決める

            # dropout_number をランダムに設定（最大値 max_dropout_number 以下の整数）
            dropout_number = random.randint(0, max_dropout_number)
            indices_to_remove = random.sample([0, 1, 2, 3], dropout_number)
            # print(indices_to_remove)

            result_pose_0to3 = remove_elements_by_indices(beat_and_pose_0to3, indices_to_remove)
            result_pose_4to7 = remove_elements_by_indices(beat_and_pose_0to3, indices_to_remove)
            result_beat_0to3 = remove_elements_by_indices(beat_0to3, indices_to_remove)
            result_beat_4to7 = remove_elements_by_indices(beat_4to7, indices_to_remove)
            # print(result_beat_0to3)
            # print(adding_beat_times[:-8])

            random_removed_output = output[:-8] + result_pose_0to3 + result_pose_4to7
            random_removed_beat_times = adding_beat_times[:-8] + result_beat_0to3 + result_beat_4to7
 



    # assert random_removed_beat_times == raw_beat_times
    return random_removed_output, random_removed_beat_times

# Example input data (same as before)
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

# Generate the dance poses
beat_pose_dictionary, beat_times = generate_robot_dance_fixed_pattern(raw_beat_times, head_ud_pose_segment, head_lr_pose_segment, left_arm_pose_segment, right_arm_pose_segment, invalid_move, brightness, smoothness)


# === Lisp形式でファイル出力 ===

# 出力ファイル名を "data_<曲名>.txt" に設定
output_filename = f"jedy_dance_subscribe_{data_file}.l"

# 既に存在する場合は削除して再生成
if os.path.exists(output_filename):
    os.remove(output_filename)
    print(f"旧ファイル {output_filename} を削除しました。")

# ファイルに書き込み
with open(output_filename, 'w') as f:
    f.write("#!/usr/bin/env roseus\n")
    # beat-pose-dictionary 出力
    f.write("(setq beat-pose-dictionary '(\n")
    for beat_and_pose in beat_pose_dictionary:
        line = "  (" + " ".join(map(str, beat_and_pose)) + ")\n"
        f.write(line)
    f.write("))\n\n")

    # beat-times 出力
    f.write("(setq beat-times '(" + " ".join(map(str, beat_times)) + "))\n\n")

    # smoothness 出力
    f.write(f"(setq smoothness {smoothness})\n\n")
    f.write(""";; 結果を出力
(print "Converted beat-times:")
(print beat-times)
(print "Converted beat-pose-dictionary:")
(print beat-pose-dictionary)




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


(ros::ros-info "~A" beat-pose-dictionary)


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

(defun get-next-info (current-position beat-pose-dictionary current-index current-beat smoothness)
  "Returns the information for the next beat if the current position is close to the current beat."
  (let* ((current-beat-and-pose (nth current-index beat-pose-dictionary)) ;; 現在のビート情報
         (tolerance 0.1)) ;; 許容誤差（例: 100ms）
    
    ; ; 変数の状態を出力
    ; (format t "DEBUG: current-position=~A, current-beat=~A, current-index=~A~%"
    ;         current-position current-beat current-index)
    
    ;; 近いビートがあるかどうかを確認
    (if (or (<= (abs (- current-position current-beat)) tolerance) ;; 最初のビートも許容
            (= current-index 0))                                 ;; 最初のビートを強制的に処理
        (progn
          (format t "DEBUG: Close enough or first beat - checking next beat~%")
          ; (let ((next-index (1+ current-index))) ;; 次のインデックスを計算
          (let ((next-index (+ 1 current-index))) ;; 次のインデックスを計算

            ;; 次のインデックスが範囲内か確認
            (if (< next-index (length beat-pose-dictionary))
                (let* ((next-beat-and-pose (nth next-index beat-pose-dictionary)) ;; 次のビート情報
                       (next-time (car next-beat-and-pose))                        ;; 次のビート時刻
                       (next-pose (cdr next-beat-and-pose)))                       ;; 次のビートのポーズ
                  ;; 結果を計算して返す
                  (format t "DEBUG: Found next beat at index ~A: next-time=~A, next-pose=~A~%"
                          next-index next-time next-pose)
                  (list (* smoothness (- next-time current-position)) next-time next-pose next-index))
                ;; 次のインデックスが範囲外の場合のログ
                (progn
                  ; (format t "DEBUG: Next index (~A) is out of range~%" next-index)
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
      (let* ((current-index-and-beat  (set-current-index *current-position* beat-times))
            (current-index  (car current-index-and-beat))
            (current-beat (first (cdr current-index-and-beat))))
        ; (ros::ros-info "current-index: ~A" current-index)

        ;;次のビートの情報を取得
        (setq next-info-list (get-next-info *current-position* beat-pose-dictionary current-index current-beat smoothness))
        (if next-info-list
            (let ((time-diff (nth 0 next-info-list))
                  (next-beat (nth 1 next-info-list))
                  (pose (remove-if #'null (nth 2 next-info-list)));; なぜか含まれるnilを取り除く
                  (next-index (nth 3 next-info-list)))  ;; 新しいインデックス

              ; (ros::ros-info "*current-position*: ~A seconds" *current-position*)

              ; 次のビートの情報とポーズを送信
              (ros::ros-info "next-index: ~A | next-beat: ~A | seconds pose:~A " next-index next-beat pose)
              (ros::ros-info "time-diff: ~A" time-diff)
              (when *use-robot* (send *jedy* :angle-vector pose))

              ;; 時刻差に応じて補間(* 1000 time-diff)、wait-interpolation
              (when *use-robot*
                ; (ros::ros-info "before-move: ~A seconds" (- (send (ros::time-now) :to-sec) (send start-time :to-sec)))
                (send *ri* :angle-vector (send *jedy* :angle-vector) time-diff :default-controller 0 :min-time 0.1)
                ;; (ros::ros-info "after-move: ~A seconds" (- (send (ros::time-now) :to-sec) (send start-time :to-sec)))
                (send *ri* :wait-interpolation)
                ;; (ros::ros-info "after-wait: ~A seconds" (- (send (ros::time-now) :to-sec) (send start-time :to-sec)))
              )
    
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
                 (ros::spin-once)))""")
print(f"Saved Lisp-style data and common part to {output_filename}")