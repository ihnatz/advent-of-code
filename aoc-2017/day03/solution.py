from collections import defaultdict
from itertools import cycle, islice, product

M = 368078

def mdist(a, b):
  return abs(a[0] - b[0]) + abs(a[1] - b[1])

def spiral():
  dirs = [(1, 0), (0, -1), (-1, 0), (0, 1)]
  x, y = 0, 0
  cycle_len, current = 1, 1

  yield((x, y))
  for dx, dy in cycle(dirs):
    for _ in range(cycle_len):
      x += dx; y += dy
      current += 1
      yield((x, y))
    if dx == 0:
      cycle_len += 1

def sumspiral():
  it = islice(spiral(), 1, None)
  mem = defaultdict(int)
  mem[(0, 0)] = 1

  while True:
    x, y = next(it)
    mem[(x, y)] = sum(mem[(x + nx, y + ny)] for nx, ny in product((-1, 0, 1), (-1, 0, 1)))
    yield(mem[(x, y)])

print(mdist((0, 0), next(islice(spiral(), M - 1, None))))
print(next(x for x in sumspiral() if x > M))
