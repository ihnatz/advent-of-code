file = open("input.txt").readlines()

class DisjointUnion:
  def __init__(self, n):
    self.parent = list(range(n))
    self.rank = [0] * n

  def find(self, x):
    if self.parent[x] != x:
      self.parent[x] = self.find(self.parent[x])
    return self.parent[x]

  def union(self, x, y):
    fx = self.find(x)
    fy = self.find(y)

    if fx == fy: return

    if self.rank[fx] > self.rank[fy]:
      self.parent[fx] = fy
    elif self.rank[fy] > self.rank[fx]:
      self.parent[fy] = fx
    else:
      self.parent[fx] = fy
      self.rank[fy] += 1
    return True

du = DisjointUnion(len(file))
for line in file:
  src, dists = line.split(" <-> ")
  f = int(src)
  for t in set(map(int, dists.split(","))):
    du.union(f, t)

root = du.find(0)
print(sum(1 for parent in du.parent if du.find(parent) == root))
print(len({du.find(parent) for parent in du.parent}))
