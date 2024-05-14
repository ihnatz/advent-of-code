with open("input.txt") as f:
    content = f.read()

lines = [level.split("\n") for level in content.split("\n\n")]


def to_range(s):
    destination_range_start, source_range_start, range_length = s
    return (
        range(source_range_start, source_range_start + range_length),
        destination_range_start - source_range_start,
    )


seeds = [int(i) for i in lines.pop(0)[0].replace("seeds: ", "").split()]

levels = [level[1:] for level in lines]
levels = [[i.split() for i in level] for level in levels]
levels = [[to_range([int(num) for num in i]) for i in level] for level in levels]

t = []
for num in seeds:
    for level in levels:
        for values_range, offset in level:
            if num in values_range:
                num += offset
                break
    t.append(num)

part1 = min(t)


# s for seed
# n for next level
def intersect(sl, sr, nl, nr):
    if sr < nl or sr > nr:  # 1 + 5
        return None
    if nl <= sl and nr >= sr:  # 3
        return (
            (sl, sr),
            None,
        )
    if sl < nl and sr >= nl and sr <= nr:  # 2
        return (
            (nl, sr),
            (sl, nl - 1) if nl - 1 >= sl else None,
        )
    if sl > nl and sl <= nr and sr >= nr:  # 4
        return (
            (sl, nr),
            (nl, sl - 1) if sl - 1 >= nl else None,
        )

    print(f"Unknown: [{sl}, {sr}], [{nl}, {nr}]")

    raise


seed_ranges = [(st, st + length - 1) for st, length in zip(seeds[::2], seeds[1::2])]
q = [(seed_range[0], seed_range[1], 0) for seed_range in seed_ranges]
t = []
while q:
    sl, sr, level_id = q.pop(0)
    if level_id == len(levels):
        t.append(sl)
        continue

    for candidate_range, offset in levels[level_id]:
        new_level = intersect(sl, sr, candidate_range[0], candidate_range[-1])
        if new_level:
            matched, rest = new_level
            q.append((matched[0] + offset, matched[1] + offset, level_id + 1))
            if rest:
                q.append((rest[0], rest[1], level_id))
            break
    else:
        q.append((sl, sr, level_id + 1))

part2 = min(t)

print(part1)
print(part2)
