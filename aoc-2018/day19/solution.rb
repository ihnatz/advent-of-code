input = File.read("input.txt")
# input = File.read("sample.txt")

INSTRUCTIONS = {
  addr: ->(a, b, c, regs) { regs[c] = regs[a] + regs[b]; regs },
  addi: ->(a, b, c, regs) { regs[c] = regs[a] + b; regs },
  mulr: ->(a, b, c, regs) { regs[c] = regs[a] * regs[b]; regs },
  muli: ->(a, b, c, regs) { regs[c] = regs[a] * b; regs },
  banr: ->(a, b, c, regs) { regs[c] = regs[a] & regs[b]; regs },
  bani: ->(a, b, c, regs) { regs[c] = regs[a] & b; regs },
  borr: ->(a, b, c, regs) { regs[c] = regs[a] | regs[b]; regs },
  bori: ->(a, b, c, regs) { regs[c] = regs[a] | b; regs },
  setr: ->(a, b, c, regs) { regs[c] = regs[a]; regs },
  seti: ->(a, b, c, regs) { regs[c] = a; regs },
  gtir: ->(a, b, c, regs) { regs[c] = a > regs[b] ? 1 : 0; regs },
  gtri: ->(a, b, c, regs) { regs[c] = regs[a] > b ? 1 : 0; regs },
  gtrr: ->(a, b, c, regs) { regs[c] = regs[a] > regs[b] ? 1 : 0; regs },
  eqir: ->(a, b, c, regs) { regs[c] = a == regs[b] ? 1 : 0; regs },
  eqri: ->(a, b, c, regs) { regs[c] = regs[a] == b ? 1 : 0; regs },
  eqrr: ->(a, b, c, regs) { regs[c] = regs[a] == regs[b] ? 1 : 0; regs }
}


lines = input.split("\n").map(&:strip)
ip, *instructions = lines
instructions = instructions.map { |line, idx|
  opcode, *inputs = line.split(" ")

  opcode = opcode.to_sym
  inputs = inputs.map(&:to_i)

  [opcode, inputs]
}

bound = ip.match(/\d+/)[0].to_i

require 'set'


def run(regs, instructions, bound, part2 = false)
  loop do
    break unless instructions[regs[bound]]

    if part2 && regs[0] == 0
      x = regs[1]
      return (1..x).select { x % _1 == 0 }.sum
    end

    opcode, inputs = instructions.fetch(regs[bound])
    INSTRUCTIONS.fetch(opcode).call(*inputs, regs)
    regs[bound] += 1
  end

  regs
end

regs = Array.new(6, 0)
part1 = run(regs, instructions, bound)[0]

regs = Array.new(6, 0)
regs[0] = 1
part2 = run(regs, instructions, bound, true)

p [part1, part2]
