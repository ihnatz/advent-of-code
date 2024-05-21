dirs = {
  'n': (0, -2), 'nw': (-1, -1), 'ne': ( 1, -1),
  's': (0,  2), 'se': ( 1,  1), 'sw': (-1,  1),
}

def dist(x, y): return abs(x) + (abs((abs(y) - abs(x))) // 2)

input = open("input.txt").read()
furthest = 0
x, y = 0, 0
for dir in input.strip().split(","):
  dx, dy = dirs[dir]
  x, y = x + dx, y + dy
  furthest = max(furthest, dist(x, y))

print(dist(x, y))
print(furthest)
