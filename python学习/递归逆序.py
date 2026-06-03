def reverse_recursive(s):
    # 递归终止条件
    if len(s) <= 1:
        return s
    # 递归公式：后面的逆序 + 第一个字符
    return reverse_recursive(s[1:]) + s[0]

user_input = input("请输入字符串: ")
print(f"逆序结果: {reverse_recursive(user_input)}")