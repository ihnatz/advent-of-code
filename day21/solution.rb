require "set"

input = File.read("input.txt")

INSTRUCTIONS = {
  addr: ->(a, b, c, regs) { regs[c] = regs[a] + regs[b] },
  addi: ->(a, b, c, regs) { regs[c] = regs[a] + b },
  mulr: ->(a, b, c, regs) { regs[c] = regs[a] * regs[b] },
  muli: ->(a, b, c, regs) { regs[c] = regs[a] * b },
  banr: ->(a, b, c, regs) { regs[c] = regs[a] & regs[b] },
  bani: ->(a, b, c, regs) { regs[c] = regs[a] & b },
  borr: ->(a, b, c, regs) { regs[c] = regs[a] | regs[b] },
  bori: ->(a, b, c, regs) { regs[c] = regs[a] | b },
  setr: ->(a, b, c, regs) { regs[c] = regs[a] },
  seti: ->(a, b, c, regs) { regs[c] = a },
  gtir: ->(a, b, c, regs) { regs[c] = a > regs[b] ? 1 : 0 },
  gtri: ->(a, b, c, regs) { regs[c] = regs[a] > b ? 1 : 0 },
  gtrr: ->(a, b, c, regs) { regs[c] = regs[a] > regs[b] ? 1 : 0 },
  eqir: ->(a, b, c, regs) { regs[c] = a == regs[b] ? 1 : 0 },
  eqri: ->(a, b, c, regs) { regs[c] = regs[a] == b ? 1 : 0 },
  eqrr: ->(a, b, c, regs) { regs[c] = regs[a] == regs[b] ? 1 : 0 }
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

def run_part1(regs, instructions, bound)
  loop do
    break if regs[bound] == 28
    opcode, inputs = instructions.fetch(regs[bound])
    INSTRUCTIONS.fetch(opcode).call(*inputs, regs)
    regs[bound] += 1
  end
  regs[4]
end

def run_part2_long(regs, instructions, bound)
  last = 0
  known = Set.new

  loop do
    if regs[bound] == 17
      regs[2] = regs[3] / 256
      regs[bound] = 20
      next
    end

    break if regs[bound] > 30

    if regs[bound] == 28
      return last if known.include?(regs[4])
      last = regs[4]
      known << regs[4]
    end

    opcode, inputs = instructions[regs[bound]]
    INSTRUCTIONS[opcode].call(*inputs, regs)
    regs[bound] += 1
  end

  last
end

def run_part2_short
  known = Set.new
  last = nil
  r0, r4, r5 = 0, 0, 0

  loop do
    return last if known.include?(r4)

    known << r4
    last = r4

    r5 = r4 | 65536
    r4 = 10552971
    loop do
      r4 = ((r4 + (r5 & 255)) & 16777215) * 65899 & 16777215
      break if r5 < 256
      r5 /= 256
    end

    break if r4 == r0
  end
end

part1 = run_part1(Array.new(6, 0), instructions, bound)
# part2 = run_part2_long(Array.new(6, 0), instructions, bound)
part2 = run_part2_short

p [part1, part2]
