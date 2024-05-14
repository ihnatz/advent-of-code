layout = [l.strip() for l in open("input.txt").readlines()]

def count_visited(start):
    beams = [start]
    passed = set()

    while beams:
        beam = beams.pop(0)
        x, y, d = beam
        if (
            not (0 <= x < len(layout[0]) and 0 <= y < len(layout))
            or (x, y, d) in passed
        ):
            continue
        passed.add((x, y, d))

        if (
            layout[y][x] == "."
            or (layout[y][x] == "-" and d in ["e", "w"])
            or (layout[y][x] == "|" and d in ["n", "s"])
        ):
            dx, dy = {"e": (1, 0), "w": (-1, 0), "n": (0, -1), "s": (0, 1)}[d]
            beams.append((x + dx, y + dy, d))
        elif (layout[y][x] == "/" and d == "e") or (layout[y][x] == "\\" and d == "w"):
            beams.append((x, y - 1, "n"))
        elif (layout[y][x] == "/" and d == "w") or (layout[y][x] == "\\" and d == "e"):
            beams.append((x, y + 1, "s"))
        elif (layout[y][x] == "/" and d == "n") or (layout[y][x] == "\\" and d == "s"):
            beams.append((x + 1, y, "e"))
        elif (layout[y][x] == "/" and d == "s") or (layout[y][x] == "\\" and d == "n"):
            beams.append((x - 1, y, "w"))
        elif layout[y][x] == "-" and d in ["n", "s"]:
            beams.append((x + 1, y, "e"))
            beams.append((x - 1, y, "w"))
        elif layout[y][x] == "|" and d in ["e", "w"]:
            beams.append((x, y + 1, "s"))
            beams.append((x, y - 1, "n"))
        else:
            raise Exception("Unknown case")
    return {(t[0], t[1]) for t in passed}


print(len(count_visited((0, 0, "e"))))

edges = (
    [(x, 0, "s") for x in range(len(layout[0]))]
    + [(0, y, "e") for y in range(len(layout))]
    + [(x, len(layout) - 1, "n") for x in range(len(layout[0]))]
    + [(len(layout[0]) - 1, y, "w") for y in range(len(layout))]
)
print(max(len(count_visited(start)) for start in edges))
