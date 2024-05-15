content = open("input.txt").readlines()


def canon(word):
    return "".join(sorted(word))


def words(line):
    return line.strip().split(" ")


print(sum(len(words) == len(set(words)) for words in [words(line) for line in content]))

print(
    sum(
        len(words) == len(set(words))
        for words in [list(map(canon, words(line))) for line in content]
    )
)
