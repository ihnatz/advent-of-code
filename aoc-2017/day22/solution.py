clean_chr = '.'
infected_chr = '#'

content = open("input.txt").read().strip()
grid = tuple(tuple(line) for line in content.split("\n"))
dirs = ((0, -1), (1, 0), (0, 1), (-1, 0))

def infected_map(grid):
  midx, midy = len(grid[0]) // 2, len(grid) // 2
  infected = set()
  for y, line in enumerate(grid):
    for x, c in enumerate(line):
      if c == infected_chr:
        infected.add((x - midx, y - midy))
  return infected

def debug_basic(virus, infected, offset = 3):
  minx = min(x for x, _ in infected)
  maxx = max(x for x, _ in infected)
  miny = min(y for _, y in infected)
  maxy = max(y for _, y in infected)
  for y in range(miny - offset, maxy + offset):
    for x in range(minx - offset, maxx + offset):
      c = infected_chr if (x, y) in infected else clean_chr
      if (x, y) == virus:
        print(f"[{c}]", end='')
      else:
        pad = "" if (x + 1, y) == virus else " "
        print(f"{c}{pad}", end='')
    print()
  print()

current_dir = 0
virus = (0, 0)
infected = infected_map(grid)
infecting = 0

for _ in range(10000):
  turn = 1 if virus in infected else -1
  current_dir = (current_dir + turn) % 4
  if virus not in infected:
    infecting += 1
    infected.add(virus)
  else:
    infected.remove(virus)
  virus = tuple(map(sum, zip(virus, dirs[current_dir])))
print(infecting)

# ------------------------------------------------------------------------------
def debug_evolved(virus, infected, weakened, flagged, offset = 3):
  known_points = infected | weakened | flagged
  minx = min(x for x, _ in known_points)
  maxx = max(x for x, _ in known_points)
  miny = min(y for _, y in known_points)
  maxy = max(y for _, y in known_points)
  for y in range(miny - offset, maxy + offset):
    for x in range(minx - offset, maxx + offset):
      if (x, y) in infected:
        c = "#"
      elif (x, y) in weakened:
        c = 'W'
      elif (x, y) in flagged:
        c = 'F'
      else:
        c = '.'

      if (x, y) == virus:
        print(f"[{c}]", end='')
      else:
        pad = "" if (x + 1, y) == virus else " "
        print(f"{c}{pad}", end='')
    print()
  print()


weakened = set()
infected = infected_map(grid)
flagged  = set()
virus = (0, 0)
current_dir = 0
infecting = 0

for _ in range(10000000):
  if virus in weakened:
    turn = 0
  elif virus in infected:
    turn = 1
  elif virus in flagged:
    turn = 2
  else:
    turn = -1
  current_dir = (current_dir + turn) % 4

  if virus in weakened:
    weakened.remove(virus)
    infected.add(virus)
    infecting += 1
  elif virus in infected:
    infected.remove(virus)
    flagged.add(virus)
  elif virus in flagged:
    flagged.remove(virus)
  else:
    weakened.add(virus)
  virus = tuple(map(sum, zip(virus, dirs[current_dir])))
print(infecting)
