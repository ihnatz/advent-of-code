from math import trunc

hailstones = [
    list(map(int, line.strip().replace(" @ ", ", ").split(", ")))
    for line in open("input.txt").readlines()
]
area = (200000000000000, 400000000000000)

def hailstone_to_line(hailstone):
    x, y, _z, dx, dy, _dx = hailstone
    x1, y1, x2, y2 = x, y, x + dx, y + dy
    # y1 = k*x1 + b
    # y2 = k*x2 + b
    # y1 - k*x1 = y2 - k*x2
    # y1 - y2 = k*(x1 - x2)
    k = (y1 - y2) / (x1 - x2)
    b = y1 - k * x1
    return (k, b)

def intersect(line1, line2):
    k1, b1 = hailstone_to_line(line1)
    k2, b2 = hailstone_to_line(line2)
    # k1*x + b1 == k2*x + b2
    # x * (k1 - k2) = b2 - b1

    if k1 == k2: # parallel
        return None

    x = (b2 - b1) / (k1 - k2)
    y = k1 * x + b1

    return (x, y)


def is_valid(stone1, stone2, point, area):
    if point is None:
        return False
    x1, y1, _z, dx1, dy1, _dz = stone1
    x2, y2, _z, dx2, dy2, _dz = stone2
    px, py = point
    amin, amax = area

    if (
        (not (amin <= px <= amax) or not (amin <= py <= amax))
        or ((dx1 > 0 and px < x1) or (dx1 < 0 and px > x1))
        or ((dy1 > 0 and py < y1) or (dy1 < 0 and py > y1))
        or ((dx2 > 0 and px < x2) or (dx2 < 0 and px > x2))
        or ((dy2 > 0 and py < y2) or (dy2 < 0 and py > y2))
    ):
        return False

    return True


t = 0
for idx, s1 in enumerate(hailstones):
    for s2 in hailstones[idx + 1 :]:
        if is_valid(s1, s2, intersect(s1, s2), area):
            t += 1
print(t)


sx = set(range(min(h[3] for h in hailstones) - 1, max(h[3] for h in hailstones) + 1))
sy = set(range(min(h[4] for h in hailstones) - 1, max(h[4] for h in hailstones) + 1))
sz = set(range(min(h[5] for h in hailstones) - 1, max(h[5] for h in hailstones) + 1))

for idx, stone1 in enumerate(hailstones):
    for stone2 in hailstones[idx + 1:]:
        x1, y1, z1, dx1, dy1, dz1 = stone1
        x2, y2, z2, dx2, dy2, dz2 = stone2

        if x2 > x1 and dx2 > dx1:
            sx -= set(range(dx1 + 1, dx2))
        if y2 > y1 and dy2 > dy1:
            sy -= set(range(dy1 + 1, dy2))
        if z2 > z1 and dz2 > dz1:
            sz -= set(range(dz1 + 1, dz2))

def cross_product(a, b):
    return [
        a[1]*b[2] - a[2]*b[1],
        a[2]*b[0] - a[0]*b[2],
        a[0]*b[1] - a[1]*b[0]
    ]

def dot_product(a, b):
    return sum([a[i]*b[i] for i in range(len(a))])


def lines_intersect(line1, line2):
    x1, y1, z1, dx1, dy1, dz1 = line1
    x2, y2, z2, dx2, dy2, dz2 = line2

    d1 = [dx1, dy1, dz1]
    d2 = [dx2, dy2, dz2]

    p21 = [x2 - x1, y2 - y1, z2 - z1]
    cross_d1_d2 = cross_product(d1, d2)

    return abs(dot_product(p21, cross_d1_d2)) < 1e-9

sdx, sdy, sdz = 0, 0, 0
for ndx in sx:
    for ndy in sy:
        for ndz in sz:
            new_lines = [[x, y, z, dx - ndx, dy - ndy, dz - ndz] for x, y, z, dx, dy, dz in hailstones]
            if all(lines_intersect(new_lines[0], line) for line in new_lines[1:]):
                sdx, sdy, sdz = ndx, ndy, ndz
                break


stone1 = hailstones[0]
stone2 = hailstones[1]

x1, y1, z1, dx1, dy1, dz1 = stone1
x2, y2, z2, dx2, dy2, dz2 = stone2

intx, inty = intersect([x1, y1, z1, dx1 - sdx, dy1 - sdy, dz1 - sdz], [x2, y2, z2, dx2 - sdx, dy2 - sdy, dz2 - sdz])
t = trunc((intx - x1) / (dx1 - sdx)) # time to collision
sx, sy, sz = x1 + t * dx1, y1 + t * dy1, z1 + t * dz1 # collision

print(sum([sx - (sdx * t), sy - (sdy * t), sz - (sdz * t)]))
