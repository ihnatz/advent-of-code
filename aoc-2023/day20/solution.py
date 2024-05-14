import math
from functools import reduce

LOW, HIGH = False, True
OFF, ON = False, True

content = open("input.txt").readlines()
destinations = {'button': ['broadcaster']}
types = {'button': 'button'}

for line in content:
    l, r = line.strip().split(" -> ")
    type, name = l[0], l[1:]
    if type in "%&":
        types[name] = type
        destinations[name] = r.split(", ")
    else:
        types[l] = l
        destinations[l] = r.split(", ")


for output in set(k for values in destinations.values() for k in values):
    if output not in types:
        types[output] = 'untyped'


def reset():
    state = {}
    for current in sorted(destinations.keys()):
        type = types[current]
        if type in ['broadcaster', 'button', 'untyped']:
            continue
        elif type == "%":
            state[current] = OFF
        elif type == "&":
            to_remember = [key for key, destination in destinations.items() if current in destination]
            state[current] = dict([[key, LOW] for key in sorted(to_remember)])
    return state


def lcm(a, b):
    return abs(a * b) // math.gcd(a, b)


def tick(state, i, cycles):
    q = [('broadcaster', LOW, 'button')]
    h, l = 0, 0


    while q:
        receiver, signal, sender = q.pop(0)

        if receiver == "vd" and signal == HIGH:
            if not cycles[sender]:
                cycles[sender] = i
            if all(cycles.values()):
                print(reduce(lcm, cycles.values()))
                exit(0)

        if signal == HIGH:
            h += 1
        else:
            l += 1

        if types[receiver] == 'broadcaster':
            pulse = signal
            for destination in destinations[receiver]:
                q.append((destination, signal, receiver))

        elif types[receiver] == '%':
            if signal == LOW:
                state[receiver] = not state[receiver]

                pulse = state[receiver]
                for destination in destinations[receiver]:
                    q.append((destination, pulse, receiver))
        elif types[receiver] == '&':
            state[receiver][sender] = signal

            pulse = not all(state[receiver].values())
            for destination in destinations[receiver]:
                q.append((destination, pulse, receiver))

    return (h, l)

values = reset()
th, tl = 0, 0
for i in range(0, 1000):
    h, l = tick(values, i, {})
    th += h
    tl += l
print(th * tl)

cycles = dict([[sender, None] for sender, receivers in destinations.items() if "vd" in receivers])
values = reset()
i = 0
while True:
    i += 1
    tick(values, i, cycles)
