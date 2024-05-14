from collections import defaultdict
from math import prod

lines = [line.strip() for line in open("input.txt").readlines()]

numbers = []
for row, line in enumerate(lines):
    current_num = []
    sc = None

    for column, c in enumerate(line):
        if c.isdigit():
            current_num.append(c)
            if sc is None:
                sc = (row, column)
        else:
            if len(current_num) > 0:
                numbers.append((int("".join(current_num)), sc))
                current_num = []
                sc = None

gears = defaultdict(list)
max_row, max_col = len(lines), len(lines[0])
total = 0
adjs = [
    (0, 1),
    (1, 0),
    (0, -1),
    (-1, 0),
    (1, 1),
    (-1, -1),
    (1, -1),
    (-1, 1),
]

for num, sc in numbers:
    r = sc[0]
    adjusted = False
    for c in range(sc[1], sc[1] + len(str(num))):
        if adjusted:
            break
        for dx, dy in adjs:
            if r + dy in range(max_row) and c + dx in range(max_col):
                char = lines[r + dy][c + dx]
                if char.isdigit() or char == ".":
                    continue
                if char == "*":
                    gears[(r + dy, c + dx)].append(num)
                adjusted = True
                break

    if adjusted:
        total += num

part1 = total
part2 = sum([prod(v) for k, v in gears.items() if len(v) == 2])

print(part1)
print(part2)
