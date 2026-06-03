from datetime import date

def day_of_year():
    y = int(input("年: "))
    m = int(input("月: "))
    d = int(input("日: "))
    target_date = date(y, m, d)
    return int(target_date.strftime("%j"))

print(f"这是该年的第 {day_of_year()} 天")