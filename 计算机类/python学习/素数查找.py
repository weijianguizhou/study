def is_prime(n):
    if n < 2: return False
    for i in range(2, int(n**0.5) + 1):
        if n % i == 0: return False
    return True

def print_primes_under_500():
    primes = [x for x in range(2, 501) if is_prime(x)]
    for i in range(len(primes)):
        print(f"{primes[i]:>4}", end=" ")
        # 每10个换行
        if (i + 1) % 10 == 0:
            print()

print_primes_under_500()