from functools import lru_cache
from collections import defaultdict
import heapq

content = open("input.txt").read().strip()
pairs = {tuple(map(int, line.split('/'))) for line in content.split("\n")}

known_digits = defaultdict(set)
for f, t in pairs:
  known_digits[f].add((f, t))
  known_digits[t].add((f, t))

strongnest = 0

q = [((f, t), {(f, t)}, -(f + t)) for f, t in pairs if f == 0]
heapq.heapify(q)
while q:
  (f, t), path, current_strongness = heapq.heappop(q)

  strongnest = min(strongnest, current_strongness)

  for pair in known_digits[t] - path:
    current = pair if t == pair[0] else tuple(reversed(pair))
    heapq.heappush(q, (current, path | {pair}, current_strongness - sum(pair)))

print(-strongnest)


longest = 0
lognest_strong = 0

q = [((f, t), {(f, t)}, -1) for f, t in pairs if f == 0]
heapq.heapify(q)
while q:
  (f, t), path, current_length = heapq.heappop(q)

  if current_length < longest:
    longest = current_length
    lognest_strong = sum(map(sum, path))
  elif current_length == longest:
    lognest_strong = max(lognest_strong, sum(map(sum, path)))

  for pair in known_digits[t] - path:
    current = pair if t == pair[0] else tuple(reversed(pair))
    heapq.heappush(q, (current, path | {pair}, current_length - 1))

print(lognest_strong)
