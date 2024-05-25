import string
from collections import defaultdict

content = open("input.txt").readlines()
programm = [line for line in content]

def value(registers, value):
  return registers[value] if value in string.ascii_lowercase else int(value)

r = { register: 0 for register in 'abcdefgh' }
mulcalls = 0

ptr = 0
while 0 <= ptr < len(programm):
  current = programm[ptr]
  op, x, y = current.split()
  if   op == 'set': r[x] =  value(r, y)
  elif op == 'sub': r[x] -= value(r, y)
  elif op == 'mul': r[x] *= value(r, y); mulcalls += 1
  elif op == 'jnz' and value(r, x): ptr += value(r, y) - 1
  ptr += 1
print(mulcalls)

import math
def is_prime(val):
  for i in range(2, int(math.sqrt(val)) + 1):
    if val % i == 0:
      return False
  return True

b = 109900
c = 126900
print(sum(not is_prime(i) for i in range(b, c + 1, 17)))
