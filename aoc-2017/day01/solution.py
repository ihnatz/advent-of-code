digits = list(map(int, open("input.txt").read().strip()))
n = len(digits)

for jump in [1, n // 2]:
  print(sum(digits[i]
    for i in range(n)
    if digits[i] == digits[(i + jump) % n]))
