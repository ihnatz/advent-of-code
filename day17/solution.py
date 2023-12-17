from collections import defaultdict
import heapq
from math import inf

layout = [list(map(int, line)) for line in open('input.txt').read().splitlines()]
opposites = {'n': 's', 's': 'n', 'e': 'w', 'w': 'e'}

def allowed_movements_crucible(way):
  stack = way[-3:]
  prev = way[-1] if way else ''

  if len(stack) < 3 or len(set(stack)) != 1:
    return [v for v in [(0, 1, 's'), (0, -1, 'n'), (1, 0, 'e'), (-1, 0, 'w')] if opposites[v[2]] != prev]
  if prev == 'w' or prev == 'e':
    return [(0, 1, 's'), (0, -1, 'n')]
  elif prev == 'n' or prev == 's':
    return [(1, 0, 'e'), (-1, 0, 'w')]
  else:
    raise Exception('Invalid direction')

open_set = []
heapq.heappush(open_set, (0, (0, 0, '')))
scores = [[defaultdict(lambda: inf) for _ in range(len(layout[0]))] for _ in range(len(layout))]
scores[0][0][''] = 0
while open_set:
  (p, (x, y, way)) = heapq.heappop(open_set)
  if x == len(layout) - 1 and y == len(layout[0]) - 1:
    print(scores[x][y][way])
    break
  for dx, dy, d in allowed_movements_crucible(way):
    nx, ny = x + dx, y + dy
    if nx < 0 or nx >= len(layout) or ny < 0 or ny >= len(layout[0]):
      continue
    new_score = scores[x][y][way] + layout[nx][ny]
    new_way = way[-2:] + d
    if new_score < scores[nx][ny][new_way]:
      scores[nx][ny][new_way] = new_score
      heapq.heappush(open_set, (new_score, (nx, ny, new_way)))

def allowed_movements_ultra_crucible(way):
  uniq_last_4 = set(way[-4:])
  uniq_last_10 = set(way[-10:])
  prev = way[-1] if way else ''

  if len(way) == 0: return [(0, 1, 's'), (0, -1, 'n'), (1, 0, 'e'), (-1, 0, 'w')]
  if len(way) < 4: return [v for v in [(0, 1, 's'), (0, -1, 'n'), (1, 0, 'e'), (-1, 0, 'w')] if v[2] == prev]
  if len(way) > 9 and len(uniq_last_10) == 1: return [v for v in [(0, 1, 's'), (0, -1, 'n'), (1, 0, 'e'), (-1, 0, 'w')] if v[2] != prev and v[2] != opposites[prev]]
  if len(uniq_last_4) == 1: return [v for v in [(0, 1, 's'), (0, -1, 'n'), (1, 0, 'e'), (-1, 0, 'w')] if opposites[v[2]] != prev]
  if len(uniq_last_4) > 1: return [v for v in [(0, 1, 's'), (0, -1, 'n'), (1, 0, 'e'), (-1, 0, 'w')] if v[2] == prev]

  raise Exception('Invalid direction', way)

open_set = []
heapq.heappush(open_set, (0, (0, 0, '')))
scores = [[defaultdict(lambda: inf) for _ in range(len(layout[0]))] for _ in range(len(layout))]
scores[0][0][''] = 0

while open_set:
  (p, (x, y, way)) = heapq.heappop(open_set)
  if x == len(layout[0]) - 1 and y == len(layout) - 1 and len(set(way[-4:])) == 1:
    print(scores[y][x][way])
    break
  for dx, dy, d in allowed_movements_ultra_crucible(way):
    nx, ny = x + dx, y + dy
    if nx < 0 or nx >= len(layout[0]) or ny < 0 or ny >= len(layout):
      continue
    new_score = scores[y][x][way] + layout[ny][nx]
    new_way = way[-9:] + d
    if new_score < scores[ny][nx][new_way]:
      scores[ny][nx][new_way] = new_score
      heapq.heappush(open_set, (new_score, (nx, ny, new_way)))
