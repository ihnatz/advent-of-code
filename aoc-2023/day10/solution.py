content = [list(line) for line in open("input.txt").read().splitlines()]
T, F = True, False

transitions = {
    #     N  E  S  W
    "-": [F, T, F, T],
    "|": [T, F, T, F],
    "L": [T, F, F, T],
    "J": [T, T, F, F],
    "7": [F, T, T, F],
    "F": [F, F, T, T],
    ".": [F, F, F, F],
    "S": [T, T, T, T],
}

start = None
for r in range(len(content)):
    for c in range(len(content[0])):
        if content[r][c] == "S":
            start = (r, c)
            break

q = [start]
loop = []
visited = set()

while q:
    current = q.pop()
    if current in visited:
        continue
    loop.append(current)
    visited.add(current)
    r, c = current
    vfrom = content[r][c]
    for new_dir, (dr, dc) in enumerate([(1, 0), (0, 1), (-1, 0), (0, -1)]):
        nr, nc = r + dr, c + dc
        if not (0 <= nr < len(content) and 0 <= nc < len(content[nr])):
            continue
        vto = content[nr][nc]
        current_dir = (new_dir + 2) % 4
        can_go = transitions[vfrom][current_dir] and transitions[vto][new_dir]

        if can_go and (nr, nc) not in visited:
            q.append((nr, nc))

part1 = len(loop) // 2

t = loop


def diff(a, b):
    # return (b[0] - a[0], b[1] - a[1])
    return (a[0] - b[0], a[1] - b[1])


mapping = {(1, 0): "N", (-1, 0): "S", (0, -1): "W", (0, 1): "E"}

cc = None
cp = None
d = []
for idx, val in enumerate(t):
    cp = cc
    cc = val
    if idx < 1:
        continue
    cdiff = diff(cc, cp)
    d.append(mapping[cdiff])


def fill(start, content, loop):
    r, c = start
    if content[r][c] == "I" or start in loop:
        return
    q = [start]
    while q:
        r, c = q.pop(0)
        if (r, c) == (0, 0):
            print("ESCAPED:", start)
        if content[r][c] == "I":
            continue
        content[r][c] = "I"

        for new_dir, (dr, dc) in enumerate([(1, 0), (0, 1), (-1, 0), (0, -1)]):
            nr, nc = r + dr, c + dc
            if not (0 <= nr < len(content) and 0 <= nc < len(content[nr])):
                continue
            if (nr, nc) in loop:
                continue
            q.append((nr, nc))


start_filling = {"W": (1, 0), "E": (-1, 0), "S": (0, -1), "N": (0, 1)}
prev = None
sloop = set(loop)

for idx, val in enumerate(t):
    if idx == 0 or idx == len(d):
        continue
    current_dir = d[idx]
    if prev != current_dir and prev is not None:
        dx, dy = start_filling[prev]
        start = (val[0] + dx, val[1] + dy)
        fill(start, content, sloop)

    dx, dy = start_filling[current_dir]
    start = (val[0] + dx, val[1] + dy)
    fill(start, content, sloop)
    prev = current_dir

part2 = sum(1 for row in content for char in row if char == "I")

print(part1)
print(part2)
