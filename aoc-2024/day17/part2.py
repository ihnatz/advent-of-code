def run(a):
  out = []
  while a != 0:
    b = (a % 8) ^ 2
    b = (b ^ a // 2**b) ^ 7
    out.append(b % 8)
    a = a // 8
  return out

E = [2, 4, 1, 2, 7, 5, 4, 3, 0, 3, 1, 7, 5, 5, 3, 0]
expected = E[:]

def run2(a):
  b = (a % 8) ^ 2
  b = (b ^ a // 2**b) ^ 7
  return b % 8

a_min = 1
a_max = 8
while len(expected) > 0:
  cur = expected.pop()

  for i in range(a_min, a_max):
    t = run2(i)
    if t == cur:
      act_run = run(i)
      if E[-len(act_run):] != act_run:
        continue
      if act_run == E:
          print(f"Part2: {i}")
      a_min = i * 8
      a_max = i * 9 - 1
      break

  else:
    print("cant find")
    exit(1)
