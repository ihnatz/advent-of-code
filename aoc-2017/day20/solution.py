import re
from collections import defaultdict

input = open("input.txt").read().strip()

def mdist(P, Q=(0, 0, 0)):
    return sum(abs(p - q) for p, q in zip(P, Q))

def parse(string):
    return tuple(map(int, string[1:-1].split(",")))

particles = []

for line in input.split("\n"):
    pp, pv, pa = re.findall(r"\<.+?\>", line)
    p, v, a = parse(pp), parse(pv), parse(pa)
    particles.append((p, v, a))

def closest(particles):
    for _ in range(1_000):
        new_generation = []
        for p, v, a in particles:
            v = tuple(map(sum, zip(v, a)))
            p = tuple(map(sum, zip(p, v)))
            new_generation.append((p, v, a))
        particles = new_generation

    return min(range(len(particles)), key=lambda i: mdist(particles[i][0]))

def not_collided(particles):
    for _ in range(1_000):
        coordinates = defaultdict(list)
        for p, v, a in particles:
            v = tuple(map(sum, zip(v, a)))
            p = tuple(map(sum, zip(p, v)))
            coordinates[p].append((p, v, a))
        particles = [
            known_particles[0]
            for known_particles in coordinates.values()
            if len(known_particles) == 1
        ]
    return len(particles)

print(closest(particles))
print(not_collided(particles))
