import re

DIGITS = {
    "one": 1,
    "two": 2,
    "three": 3,
    "four": 4,
    "five": 5,
    "six": 6,
    "seven": 7,
    "eight": 8,
    "nine": 9,
}

lines = open("input.txt").readlines()


def calculate1(line):
    digits = [int(c) for c in list(line) if c.isdigit()]
    return digits[0] * 10 + digits[-1]


def to_num(string):
    if string in DIGITS:
        return DIGITS[string]
    if string.isdigit():
        return int(string)
    raise Exception("Unknown string: " + string)


def calculate2(line):
    pattern = r"(\d|" + "|".join(["(?=(" + key + "))" for key in DIGITS.keys()]) + ")"
    matches = re.findall(pattern, line)
    digits = [to_num(match) for sublist in matches for match in sublist if match]

    return digits[0] * 10 + digits[-1]


part1 = sum([calculate1(line) for line in lines])
part2 = sum([calculate2(line) for line in lines])

print(part1)
print(part2)
