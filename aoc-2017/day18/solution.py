import string
from collections import defaultdict

content = open("input.txt").readlines()
programm = [line for line in content]

def value(registers, value):
  return registers[value] if value in string.ascii_lowercase else int(value)

def cset(registers, ptr, x, y):
  registers[x] = value(registers, y)
  return (ptr + 1, None)

def cadd(registers, ptr, x, y):
  registers[x] += value(registers, y)
  return (ptr + 1, None)

def cmul(registers, ptr, x, y):
  registers[x] *= value(registers, y)
  return (ptr + 1, None)
def cmod(registers, ptr, x, y):
  registers[x] %= value(registers, y)
  return (ptr + 1, None)

def cjgz(registers, ptr, x, y):
  if value(registers, x) > 0:
    return (ptr + value(registers, y), None)
  else:
    return (ptr + 1, None)

def csnd(registers, ptr, x):
  registers['output'] = value(registers, x)
  return (ptr + 1, None)

def crcv(registers, ptr, x):
  val = value(registers, x)
  if val != 0:
    return (ptr + 1, registers['output'])
  return (ptr + 1, None)

WRONG_MAPPING = {
  'set': cset, 'add': cadd, 'mul': cmul, 'mod': cmod,
  'snd': csnd, 'jgz': cjgz, 'rcv': crcv
}

def run(registers, mapping):
  ptr = 0
  while True:
    current = programm[ptr]
    command, *args = current.split()
    ptr, signal = mapping[command](registers, ptr, *args)
    if signal:
      yield(signal)

p  = run(defaultdict(int), WRONG_MAPPING)
print(next(p))

def nsnd(registers, ptr, x):
  return (ptr + 1, ('sending', value(registers, x)))

def nrcv(registers, ptr, x):
  if registers['inbox']:
    registers[x] = registers['inbox'].pop(0)
    registers['idle'] = False
    return (ptr + 1, None)
  else:
    registers['idle'] = True
    return (ptr, ('waiting', None))

CORRECT_MAPPING = {**WRONG_MAPPING, 'snd': nsnd, 'rcv': nrcv}

def is_stopped(r):
  return r['idle'] and not r['inbox']

r0 = defaultdict(int)
r0['p'] = 0
r0['inbox'] = []

r1 = defaultdict(int)
r1['p'] = 1
r1['inbox'] = []

t = 0

current_pid = 0
programms = (
  (run(r0, CORRECT_MAPPING), r0),
  (run(r1, CORRECT_MAPPING), r1)
)

while True:
  receiver_pid = 1 - current_pid
  runner, _ = programms[current_pid]
  message, data = next(runner)
  if message == 'sending':
    if current_pid == 1: t += 1
    _, receiver_registers = programms[receiver_pid]
    receiver_registers['inbox'].append(data)
  if is_stopped(r0) and is_stopped(r1):
    break
  current_pid = receiver_pid

print(t)
