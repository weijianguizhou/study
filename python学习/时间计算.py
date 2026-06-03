a = input("请输入时间 (格式 HH:MM:SS): ")
h = int(a[0:2])
m = int(a[3:5])
s = int(a[6:8])


def next_sec(h, m, s):
    s += 1
    if s >= 60:
        s = 0
        m += 1
    if m >= 60:
        m = 0
        h += 1
    if h >= 24:
        h = 0

    return h, m, s

h, m, s = next_sec(h, m, s)

print(f"{str(h).zfill(2)}:{str(m).zfill(2)}:{str(s).zfill(2)}")


