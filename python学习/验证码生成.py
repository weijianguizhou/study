import random
import string

def generate_code():
    pool = string.ascii_uppercase + string.digits
    code = "".join(random.choices(pool, k=6))
    return code

print(f"验证码: {generate_code()}")