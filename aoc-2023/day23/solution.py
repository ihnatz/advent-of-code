from collections import defaultdict, deque

grid = [list(line) for line in open('input.txt').read().strip().splitlines()]
finish = (len(grid) - 1, len(grid[0]) - 2)

def print_grid(grid, known):
    for r in range(len(grid)):
        for c in range(len(grid[0])):
            if (r, c) in known:
                print("O", end="")
            else:
                print(grid[r][c], end="")
        print()
    print()

def part1():
    known = {}
    q = [(0, 1, set())]

    while q:
        current = q.pop(0)
        r, c, steps = current

        if (r, c) in known and len(known[(r, c)]) >= len(steps):
            continue

        known[(r, c)] = steps
        steps = steps | {(r, c)}

        if grid[r][c] in "^<>v":
            dr, dc = {"^": (-1, 0), ">": (0, 1), "v": (1, 0), "<": (0, -1)}[grid[r][c]]
            if (r + dr, c + dc) not in steps:
                q.append((r + dr, c + dc, steps))
            continue

        for dr, cd in {(-1, 0), (0, 1), (1, 0), (0, -1)}:
            if 0 <= r + dr < len(grid) and 0 <= c + cd < len(grid[0]):
                if grid[r + dr][c + cd] != "#" and (r + dr, c + cd) not in steps:
                    q.append((r + dr, c + cd, steps))

        if (r, c) == finish:
            if len(steps) > len(known[(r, c)]):
                known[(r, c)] = steps
            continue

    print(len(known[finish]) - 1)

def compact_grid(grid):
    destinations = defaultdict(dict)
    interesting_points = [(0, 1), (len(grid) - 1, len(grid[0]) - 2)]

    for sr, row in enumerate(grid):
        for sc, cell in enumerate(row):
            if cell == "#":
                continue

            nb = 0
            for dr, dc in {(-1, 0), (0, 1), (1, 0), (0, -1)}:
                if (
                    0 <= sr + dr < len(grid)
                    and 0 <= sc + dc < len(grid[0])
                    and grid[sr + dr][sc + dc] != "#"
                ):
                    nb += 1
            if nb <= 2:
                continue
            else:
                interesting_points.append((sr, sc))

    for point in interesting_points:
        q = [(*point, 0)]
        visited = set()
        while q:
            r, c, d = q.pop(0)
            visited.add((r, c))
            for dr, dc in {(-1, 0), (0, 1), (1, 0), (0, -1)}:
                if (
                    0 <= r + dr < len(grid)
                    and 0 <= c + dc < len(grid[0])
                    and grid[r + dr][c + dc] != "#"
                ):
                    if (r + dr, c + dc) in interesting_points and (
                        r + dr,
                        c + dc,
                    ) != point:
                        destinations[point][(r + dr, c + dc)] = d + 1
                        destinations[(r + dr, c + dc)][point] = d + 1
                        break
                    if (r + dr, c + dc) not in visited:
                        q.append((r + dr, c + dc, d + 1))

    return destinations


compacted = compact_grid(grid)

q = deque([(0, 1, 0, set())])
t = 0
while q:
    current = q.pop()
    r, c, steps, visited = current

    if (r, c) == finish:
        t = max(t, steps)
        continue

    visited = visited | {(r, c)}
    for new_r, new_c in compacted[(r, c)]:
        if (new_r, new_c) not in visited and (new_r, new_r) != (r, c):
            q.append(
                (
                    new_r,
                    new_c,
                    steps + compacted[(r, c)][(new_r, new_c)],
                    visited | {(r, c)},
                )
            )
    visited.remove((r, c))

part1()
print(t)
