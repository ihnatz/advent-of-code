import random
from collections import defaultdict

content = open('input.txt').read()
nodes = list(set(content.replace("\n", " ").replace(": ", " ").split(" ")))
parents = list(range(len(nodes)))
edges = defaultdict(int)

def union(a, b):
  global parents
  ra = find(a)
  rb = find(b)
  if ra == rb:
    return
  edges[(a, b)] += 1
  parents[ra] = rb

def find(a):
  global parents
  if parents[a] == a:
    return a
  parents[a] = find(parents[a])
  return parents[a]

connections = []
for line in content.split("\n"):
  l, r =line.strip().split(": ")
  l = nodes.index(l)
  for c in [nodes.index(node) for node in r.split(" ")]:
    connections.append((l, c))

for _ in range(1500):
  parents = list(range(len(nodes)))
  random.shuffle(connections)
  for (l, c) in connections:
    union(l, c)

most_common = [sorted(list(x[0])) for x in sorted(edges.items(), key=lambda x: x[1], reverse=True)[:3]]

parents = list(range(len(nodes)))
for (l, c) in set(connections):
  if sorted([l, c]) not in most_common:
    union(l, c)

for j in range(0, len(nodes)):
  find(j)

a, b = tuple(set(parents))
print(sum([1 for p in parents if p == a]) * sum([1 for p in parents if p == b]))
