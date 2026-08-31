def extract_elements(input_str):
    # 入力の文字列から括弧を外し、要素をスペースで分割
    elements = input_str.strip("()\n").split()

    # 最初の4つの要素を抜き出し、インデックスと共に格納
    result = []
    for index in range(4):
        result.append((index, elements[index]))

    # 出力形式に整形
    output = "(" + " ".join([f"({i} {value})" for i, value in result]) + ")"
    
    return output

while 1 :
    input_data = input()
    result = extract_elements(input_data)
    print(result)

