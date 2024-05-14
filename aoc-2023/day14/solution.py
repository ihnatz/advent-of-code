lines = [line.strip() for line in open("input.txt").readlines()]

def print_field(lines, stopped, staying):
    for y, line in enumerate(lines):
        for x, char in enumerate(line):
            if (x, y) in stopped:
                print("O", end="")
            elif (x, y) in staying:
                print("#", end="")
            else:
                print(".", end="")
        print()

rolling = [(x, y) for y, line in enumerate(lines) for x, char in enumerate(line) if char == "O"]
staying = {(x, y) for y, line in enumerate(lines) for x, char in enumerate(line) if char == "#"}

[staying.update({(-1, y), (len(line), y)}) for y, line in enumerate(lines)]
[staying.update({(x, -1), (x, len(lines))}) for x in range(len(lines[0]))]

sorting = {
    (0, -1): lambda x: x[1],
    (0, 1): lambda x: -x[1],
    (-1, 0): lambda x: x[0],
    (1, 0): lambda x: -x[0],
}
def spin(lines, rolling, staying, directions=[(0, -1), (-1, 0), (0, 1), (1, 0)]):
    for dx, dy in directions:
        stopped = set()
        rolling.sort(key=sorting[(dx, dy)])
        while rolling:
            x, y = rolling.pop(0)
            if (x + dx, y + dy) in staying or (x + dx, y + dy) in stopped:
                stopped.add((x, y))
            else:
                rolling.append((x + dx, y + dy))
        rolling = list(stopped)
    return stopped

def spin_cycle(lines, rolling, staying):
    states = []
    i = 0
    stopped = None
    while stopped not in states:
        states.append(stopped)
        stopped = frozenset(spin(lines, rolling, staying))
        rolling = list(stopped)
        i += 1

    start = states.index(stopped)
    cycle = i - start
    return list(states[start + (1000000000 - start) % cycle])

print(sum([len(lines) - y for _, y in spin(lines, rolling[:], staying, directions=[(0, -1)])]))
print(sum([len(lines) - y for _, y in spin_cycle(lines, rolling[:], staying)]))
