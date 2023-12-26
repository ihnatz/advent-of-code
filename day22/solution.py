from collections import defaultdict, deque
from itertools import chain

bricks = [
    list(map(int, b.strip().replace("~", ",").split(",")))
    for b in open("input.txt").readlines()
]

bricks.sort(key=lambda x: x[2])

def overlap(b1, b2):
    return (
        max(b1[0], b2[0]) <= min(b1[3], b2[3]) and
        max(b1[1], b2[1]) <= min(b1[4], b2[4])
    )

levels = defaultdict(list)
for idx, brick in enumerate(bricks):
    height = brick[5] - brick[2]

    if idx == 0:
        brick[2], brick[5] = 1, height + 1
        levels[brick[5]].append(brick)
        continue

    level = brick[2]
    while level >= 1:
        if any(overlap(brick, b) for b in levels[level]):
            level = max(level, max(b[5] for b in levels[level]) + 1)
            break
        level -= 1
    else:
        level += 1

    brick[2], brick[5] = level, level + height
    levels[brick[5]].append(brick)


bricks = list(chain.from_iterable(levels[k] for k in sorted(levels.keys())))

supported_by = defaultdict(set)
supports = defaultdict(set)

for high, ubrick in enumerate(bricks):
    for low, lbrick in enumerate(bricks[:high]):
        if overlap(ubrick, lbrick) and lbrick[5] + 1 == ubrick[2]:
            supports[low].add(high)
            supported_by[high].add(low)

t = sum(all(len(supported_by[k]) > 1 for k in supports[i]) for i in range(len(bricks)))
print(t)


t = 0
for idx in range(len(bricks)):
    falling = set([idx])
    q = deque([idx])
    while q:
        jdx = q.popleft()
        falling.add(jdx)
        for kdx in supports[jdx]:
            if supported_by[kdx].issubset(falling):
                q.append(kdx)
    t += len(falling) - 1

print(t)
