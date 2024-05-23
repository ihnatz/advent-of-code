content = open("input.txt").read()
def alpha(): return [chr(i) for i in range(ord('a'), ord('p') + 1)]

def spin(alpha, arg1):
  arg1 = int(arg1)
  return alpha[-arg1:] + alpha[:-arg1]

assert spin(list('abcde'), '3') == list('cdeab')
assert spin(list('abcde'), '1') == list('eabcd')

def exchange(alpha, arg1, arg2):
  arg1, arg2 = int(arg1), int(arg2)
  alpha[arg1], alpha[arg2] = alpha[arg2], alpha[arg1]
  return alpha

assert exchange(list('eabcd'), '3', '4') == list('eabdc')

def partner(alpha, arg1, arg2):
  i1 = alpha.index(arg1)
  i2 = alpha.index(arg2)
  return exchange(alpha, i1, i2)

assert partner(list('eabdc'), 'e', 'b') == list('baedc')

def cycle(programms):
  for command in content.strip().split(","):
    name, args = command[0], command[1:].split("/")
    programms = { 's': spin, 'x': exchange, 'p': partner }[name](programms, *args)
  return programms

print(''.join(cycle(alpha())))

def detect_cycle(iterator):
  known_values = {}
  current_call = 0
  while True:
    next_value = next(iterator)
    if next_value in known_values:
      return (known_values[next_value], current_call - known_values[next_value])
    else:
      known_values[next_value] = current_call
      current_call += 1

assert detect_cycle(iter([1,2,3,4,5,6,7,5,6,7,5,6,7])) == (4, 3)

def dance():
  programms = alpha()
  for _ in range(1000000000):
    yield(tuple(programms))
    programms = cycle(programms)

offset, cycle_len = detect_cycle(dance())
iterations = (1000000000 - offset) % cycle_len

programms = alpha()
for _ in range(iterations):
  programms = cycle(programms)
print(''.join(programms))
