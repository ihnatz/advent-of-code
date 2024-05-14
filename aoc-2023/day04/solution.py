with open('input.txt') as f:
    lines = f.read().splitlines()

intersections = [len(set(map(int, winning.split())) & set(map(int, numbers.split())))
                 for _, numbers in (line.split(': ') for line in lines)
                 for winning, numbers in (numbers.split(' | '),)]

part1 = sum(2**(count - 1) for count in intersections if count > 0)

p = 0
cards_count = [1] * len(intersections)
for id, count in enumerate(intersections):
    p += cards_count[id]
    for i in range(count):
        cards_count[id + i + 1] += cards_count[id]

part2 = p

print(part1)
print(part2)