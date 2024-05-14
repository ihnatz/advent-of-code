from functools import reduce
from operator import mul

input = open("input.txt").read().strip()

workflows, parts = input.split("\n\n")
parts = [
    {pair.split('=')[0]: int(pair.split('=')[1]) for pair in part.strip("{}").split(",")}
    for part in parts.split("\n")
]

workflows = dict([
    [line[: line.index("{")], line[line.index("{") + 1 : -1].split(",")]
    for line in workflows.split("\n")
])


def terminate(workflows, condition):
    k, v = condition.split(":")
    return [k, list_to_tree(workflows, [v])]


def list_to_tree(workflows, arr):
    if len(arr) > 1:
        return [*terminate(workflows, arr[0]), list_to_tree(workflows, arr[1:])]
    elif len(arr) == 1:
        if arr[0] in "AR":
            return arr[0] == "A"
        else:
            return list_to_tree(workflows, workflows[arr[0]])


def shaked_tree(dtree):
    if not isinstance(dtree, list):
        return dtree
    cond, t, f = dtree
    if f == t:
        return f
    return [cond, shaked_tree(t), shaked_tree(f)]


dtree = list_to_tree(workflows, workflows["in"])
while dtree != shaked_tree(dtree):
    dtree = shaked_tree(dtree)


def go_through(dtree, x):
    current = dtree

    while not isinstance(current, bool):
        letter, op, val = current[0][0], current[0][1], int(current[0][2:])
        goto = 1 if (x[letter] > val if op == ">" else x[letter] < val) else 2
        current = current[goto]

    return sum(int(v) for v in x.values()) if current else 0

print(sum(go_through(dtree, x) for x in parts))

MIN = 1
MAX = 4000 + 1

def to_ranges(dtree):
    if not isinstance(dtree, list):
        return dtree

    current, t, f = dtree
    letter, op, val = current[0], current[1], int(current[2:])

    if op == "<":
        nc = range(MIN, val)
    else:
        nc = range(val + 1, MAX)

    return [(letter, nc), to_ranges(t), to_ranges(f)]

ranged = to_ranges(dtree)

st = {key: set(range(MIN, MAX)) for key in ["x", "m", "a", "s"]}
q = [(ranged, st)]
t = 0


while q:
    current_tree, processed = q.pop(0)

    if isinstance(current_tree, bool):
        if current_tree:
            t += reduce(mul, [len(values) for values in processed.values()])
        continue

    nletter = current_tree[0][0]
    nrange = set(current_tree[0][1])

    q.append((current_tree[1], {**processed, **{nletter: (processed[nletter] & nrange)}}))
    q.append((current_tree[2], {**processed, **{nletter: (processed[nletter] - nrange)}}))


print(t)
