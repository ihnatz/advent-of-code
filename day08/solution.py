import math
from functools import reduce


def lcm(a, b):
    return abs(a * b) // math.gcd(a, b)


with open("input.txt") as f:
    content = f.read().splitlines()

cycle = content.pop(0)
content.pop(0)

mapping = {}
for line in content:
    key, way = line.split(" = ")
    way = way.replace("(", "").replace(")", "").split(", ")
    mapping[key] = way

tick = 0
node = "AAA"
while node != "ZZZ":
    direction = cycle[tick % len(cycle)]
    node = mapping[node]["LR".index(direction)]
    tick += 1
part1 = tick

tick = 0
nodes = [node for node in mapping.keys() if node[2] == "A"]
zs = [0] * len(nodes)

while not all(zs):
    for idx, node in enumerate(nodes):
        if not zs[idx] and node[2] == "Z":
            zs[idx] = tick

    direction = cycle[tick % len(cycle)]
    nodes = [mapping[node]["LR".index(direction)] for node in nodes]
    tick += 1
part2 = reduce(lcm, zs)

print(part1)
print(part2)
