content = open("input.txt").readlines()

def run(mem, maze_len, part2=False):
  mem = instructions[:]
  ptr = 0
  iteration = 0

  while ptr < maze_len:
    jump = mem[ptr]

    if part2:
      mem[ptr] += -1 if jump >= 3 else 1
    else:
      mem[ptr] += 1

    ptr += jump
    iteration += 1
  return iteration

instructions = list(map(int, content))
maze_len = len(instructions)

print(run(instructions[:], maze_len))
print(run(instructions[:], maze_len, True))
