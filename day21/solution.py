grid = open("input.txt").read().splitlines()

sr, sc = next((r, c) for r, row in enumerate(grid) for c, ch in enumerate(row) if ch == "S")
w, h = len(grid[0]), len(grid)

def fill(sr, sc, expected):
  seen = {(sr, sc)}
  ans = set()
  q = [(sr, sc, expected)]

  while q:
    r, c, steps = q.pop(0)

    if grid[r % h][c % w] == '#':
      continue

    if steps % 2 == 0:
      ans.add((r, c))

    for dr, dc in [(-1, 0), (1, 0), (0, -1), (0, 1)]:
      nr, nc = r + dr, c + dc
      if steps > 0 and (nr, nc) not in seen:
        q.append((nr, nc, steps - 1))
        seen.add((nr, nc))

  return ans


print(len(fill(sr, sc, 64)))

y0 = len(fill(sr, sc, w // 2))
y1 = len(fill(sr, sc, w // 2 + w))
y2 = len(fill(sr, sc, w // 2 + w * 2))

# y0 = c
# y1 = a + b + c
# y2 = 4a + 2b + c == 2y1 - y0 + 2a

c = y0
a = (y2 - 2 * y1 + c) // 2
b = y1 - a - c

steps = 26501365

x = steps // w
y = a * x**2 + b * x + c

print(y)
