from itertools import groupby
from collections import Counter

with open("input.txt") as f:
    content = f.read().splitlines()

HANDS = [
    "five_of_a_kind",
    "four_of_a_kind",
    "full_house",
    "three_of_a_kind",
    "two_pairs",
    "one_pair",
    "high_card",
]

RANK1 = "AKQJT98765432"
RANK2 = "AKQT98765432J"


def calculate_power(hand, combo_func, rank):
    combo_type = combo_func(hand)
    power = HANDS.index(combo_type)
    individual = [rank.index(card) for card in hand]
    return power, individual


def power1(hand):
    return calculate_power(hand, combo, RANK1)


def power2(original, hand):
    return calculate_power(hand, combo, RANK2)


def combo(hand):
    count = Counter(sorted(hand))

    values = list(count.values())
    unique_values = len(values)

    if 5 in values:
        return "five_of_a_kind"
    if 4 in values:
        return "four_of_a_kind"
    if 3 in values and 2 in values:
        return "full_house"
    if 3 in values:
        return "three_of_a_kind"
    if unique_values == 3 and 2 in values:
        return "two_pairs"
    if unique_values == 4 and 2 in values:
        return "one_pair"
    if unique_values == 5 and 2 not in values:
        return "high_card"

    raise Exception(f"Invalid hand {hand}")


pairs = [(hand, int(rank)) for hand, rank in [line.split(" ") for line in content]]
pairs.sort(key=lambda x: power1(x[0]))
part1 = sum(rank * (len(pairs) - idx) for idx, (hand, rank) in enumerate(pairs))


def get_max_power_for(hand):
    if "J" not in hand:
        return hand, power2(hand, hand)

    candidates = [""]
    for c in hand:
        if c == "J":
            candidates = [cc + r for r in RANK1 for cc in candidates]
        else:
            candidates = [cc + c for cc in candidates]

    max_candidate = max(candidates, key=lambda candidate: power2(candidate, hand))
    return max_candidate, power2(max_candidate, hand)


pairs = [
    (get_max_power_for(hand), int(rank))
    for hand, rank in [line.split(" ") for line in content]
]
pairs.sort(key=lambda x: x[0][1])
part2 = sum(
    rank * (len(pairs) - idx) for idx, ((hand, power), rank) in enumerate(pairs)
)

print(part1)
print(part2)
