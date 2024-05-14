content = open("input.txt").readlines()

def part1(row):
  return max(row) - min(row)

def part2(row):
  return next(r // l for l in row for r in row if r > l and r != l and r % l == 0)

for func in [part1, part2]:
  print(sum(func(row)
    for row in [list(map(int, line.strip().split("\t"))) for line in content]))
