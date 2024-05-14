patterns = open("input.txt").read().split("\n\n")

def score(candidate):
    idx, vh = candidate
    return idx if vh == "v" else 100 * idx

def calculate_diff(masks):
    return sum(
        sum(lc != rc for lc, rc in zip(l, r))
        for l, r in list(zip(masks, reversed(masks)))[: len(masks) // 2]
    )

def symmetry(masked, vh, diff):
    for i in range(1, len(masked), 2):
        if calculate_diff(masked[i:]) == diff:
            return (i + len(masked[i:]) // 2, vh)
        if calculate_diff(masked[:-i]) == diff:
            return (len(masked[:-i]) // 2, vh)

def detect_mirror(pattern, diff):
    return symmetry(pattern, "h", diff) or symmetry(list(zip(*pattern)), "v", diff)

print(sum([score(detect_mirror(pattern.split("\n"), diff=0)) for pattern in patterns]))
print(sum([score(detect_mirror(pattern.split("\n"), diff=1)) for pattern in patterns]))
