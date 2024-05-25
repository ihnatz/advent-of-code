import itertools
import math

def convert(pattern):
  return tuple(tuple(map(int, chars)) for chars in pattern.translate(str.maketrans('.#', '01')).split("/"))

def options(pattern):
  for _ in range(4):
    yield pattern
    yield flip(pattern)
    yield rotate(pattern)
    yield rotate(flip(pattern))
    pattern = rotate(pattern)

def rotate(pattern):
  return tuple(zip(*reversed(pattern)))

def flip(pattern):
  return tuple(tuple(reversed(row)) for row in pattern)

def slice(pattern, side = 2):
  for y in range(0, len(pattern) // side):
    for x in range(0, len(pattern) // side):
      yield tuple(row[x * side:(x + 1) * side] for row in pattern[y * side:(y + 1) * side])

def merge(squares):
  side = int(math.sqrt(len(squares)))
  return tuple(
      tuple(itertools.chain.from_iterable(squares[i * side + k][j] for k in range(side)))
      for i in range(side)
      for j in range(len(squares[0]))
  )

def count(grid):
  return sum(sum(row) for row in grid)

def Rules(rulesstr):
  rules = {}
  for line in rulesstr.split("\n"):
    match, pattern = line.split(" => ")
    pattern = convert(pattern)
    for option in options(convert(match)):
      rules[option] = pattern
  return rules

def iterate(n, original, rules):
  current = original
  for i in range(n):
    side = 2 if len(current) % 2 == 0 else 3
    current = merge([rules[square] for square in slice(current, side)])
  return current

original = ((0,1,0), (0,0,1), (1,1,1))
rulesstr = open("input.txt").read().strip()
rules = Rules(rulesstr)

print(count(iterate(5, original, rules)))
print(count(iterate(18, original, rules)))
