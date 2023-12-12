from functools import lru_cache
import re


def to_groups(pattern):
    return tuple(map(len, filter(None, re.split(r"\.+", pattern))))


@lru_cache(maxsize=None)
def solve(pattern, groups):
    i = pattern.find("?")
    if i == -1:
        return int(to_groups(pattern) == groups)

    known_pattern = pattern[:i].rstrip("#")
    if known_pattern:
        known_groups = to_groups(known_pattern)
        if groups[: len(known_groups)] != known_groups:
            return 0
        return solve(pattern[len(known_pattern) :], groups[len(known_groups) :])

    with_pound = pattern[:i] + "#" + pattern[i + 1 :]
    with_dot = pattern[:i] + "." + pattern[i + 1 :]
    return solve(with_pound, groups) + solve(with_dot, groups)


def parse_input(line):
    pattern, groups = line.split()
    return pattern, tuple(map(int, groups.split(",")))


with open("input.txt") as f:
    lines = list(map(parse_input, f))
    part1 = sum(solve(pattern, groups) for pattern, groups in lines)
    part2 = sum(solve("?".join([pattern] * 5), groups * 5) for pattern, groups in lines)

print(part1)
print(part2)
