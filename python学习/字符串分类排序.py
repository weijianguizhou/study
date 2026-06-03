def sort_string(s):
    letters = sorted([c for c in s if c.isalpha()])
    digits = sorted([c for c in s if c.isdigit()])

    l_str = "".join(letters)
    d_str = "".join(digits)

    print(f"字母串 {l_str}, 数字串 {d_str}, 合并串: {l_str + d_str}")

a=input()
sort_string(a)