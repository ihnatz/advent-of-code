from itertools import combinations
content = open("input.txt").read().strip().splitlines()

def manhattan_distance(a, b):
  return abs(a[0] - b[0]) + abs(a[1] - b[1])

def expand(galaxies, expand_rows, expand_cols, diff):
  galaxies_copy = galaxies.copy()
  for r in reversed(expand_rows):
    galaxies_copy = [(y + diff - 1, x) if y > r else (y, x) for y, x in galaxies_copy]
  for c in reversed(expand_cols):
    galaxies_copy = [(y, x + diff - 1) if x > c else (y, x) for y, x in galaxies_copy]
  return galaxies_copy

galaxies = [(r, c) for r, line in enumerate(content) for c, char in enumerate(line) if char == '#']
expand_rows = [idx for idx, row in enumerate(content) if '#' not in row]
expand_cols = [idx for idx, col in enumerate(zip(*content)) if '#' not in col]

print(sum([manhattan_distance(*pair) for pair in list(combinations(expand(galaxies, expand_rows, expand_cols, 2), 2))]))
print(sum([manhattan_distance(*pair) for pair in list(combinations(expand(galaxies, expand_rows, expand_cols, 1000000), 2))]))
