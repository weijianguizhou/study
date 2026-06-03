def filter_above_average():
    data = input("请输入整数（空格分隔）: ")
    nums = [int(x) for x in data.split()]
    avg = sum(nums) / len(nums)

    result = [str(x) for x in nums if x > avg]
    print(" ".join(result))


# 示例输入: 143 174 119 127 117 164 110 128
filter_above_average()