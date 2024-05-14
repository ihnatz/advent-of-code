plan = open("input.txt", "r").readlines()
dirs = {"U": (-1, 0), "D": (1, 0), "L": (0, -1), "R": (0, 1)}

def count_total(steps):
    y, x = 0, 0
    area = 0
    for direction, count in steps:
        dy, dx = [d * count for d in dirs[direction]]
        y, x = y + dy, x + dx
        area += x * dy
    perimeter = sum([c for _d, c in steps])
    return area + perimeter // 2 + 1

print(count_total([
    (direction, int(count))
    for line in plan for direction, count, color in [line.strip().split()]
]))

print(count_total([
    ("RDLU"[int(color[7])], int(color.strip("()")[1:6], 16))
    for line in plan for direction, count, color in [line.strip().split()]
]))
