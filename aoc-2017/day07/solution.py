import re

content = open("input.txt").readlines()

weights = {}
children = {}
parents = {}

for line in content:
  name, w, *rest = re.findall(r'\w+', line)

  weights[name] = int(w)
  children[name] = set(rest)

  for node in rest:
    parents[node] = name

connected = {node for children in children.values() for node in children}
root = next(iter(set(weights.keys()) - connected))

def find_unballanced(array):
  sorted_array = sorted(array, key=lambda x: x[-1])
  common = sorted_array[len(array) // 2][-1]
  return next(name for name, value in array if value != common)

def total_weight(node):
  return weights[node] + sum(map(total_weight, children[node]))

current = root
while len({total_weight(node) for node in children[current]}) != 1:
  current = find_unballanced([(node, total_weight(node)) for node in children[current]])
expected_weight = next(total_weight(sibling)
  for sibling in children[parents[current]]
  if total_weight(sibling) != total_weight(current))

print(root)
print(expected_weight - total_weight(current) + weights[current])
