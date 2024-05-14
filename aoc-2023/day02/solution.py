LIMITS = (12, 13, 14)


def parse_set(gameset):
    cubes = [cube.strip() for cube in gameset]
    counts = {"red": 0, "green": 0, "blue": 0}
    for description in cubes:
        count, color = description.split(" ")
        counts[color] += int(count)
    return counts["red"], counts["green"], counts["blue"]


def parse_input(lines):
    games = []
    for line in lines:
        game, sets = line.strip().split(":")
        game = int(game.strip().split(" ")[-1])
        sets = [parse_set(gameset.split(",")) for gameset in sets.strip().split(";")]
        games.append((game, sets))
    return games


def required_cube_count(game):
    _, sets = game
    return (
        max(r for r, _, _ in sets),
        max(g for _, g, _ in sets),
        max(b for _, _, b in sets),
    )


def game_power(gameset):
    r, g, b = gameset
    return r * g * b


def is_valid_set(gameset):
    return not any(c > limit for c, limit in zip(gameset, LIMITS))


with open("input.txt") as file:
    lines = file.readlines()


games = parse_input(lines)
valid_games = [
    game for game in games if all(is_valid_set(gameset) for gameset in game[1])
]
part1 = sum([game[0] for game in valid_games])
part2 = sum([game_power(required_cube_count(game)) for game in games])

print(part1)
print(part2)
