from collections import defaultdict

BEGIN = 'A'
STEPS = 12683008

A, B, C, D, E, F = 'ABCDEF'
MACHINE = {
  A: [(1, +1, B), (0, -1, B)],
  B: [(1, -1, C), (0, +1, E)],
  C: [(1, +1, E), (0, -1, D)],
  D: [(1, -1, A), (1, -1, A)],
  E: [(0, +1, A), (0, +1, F)],
  F: [(1, +1, E), (1, +1, A)]
}

ptr = 0
slots = defaultdict(int)
state = BEGIN
for _ in range(STEPS):
  current_value = slots[ptr]
  new_value, move, new_state = MACHINE[state][current_value]
  slots[ptr] = new_value
  ptr += move
  state = new_state

print(sum(slots.values()))
