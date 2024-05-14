input = File.read("input.txt")

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

def candidates(programm)
  before, instruction, after = programm.strip.split("\n")
  opcode, inpa, inpb, outc = instruction.split(" ").map(&:to_i)
  before = before.scan(/\d+/).map(&:to_i)
  after = after.scan(/\d+/).map(&:to_i)

  opnames = INSTRUCTIONS.select { |name, opcode|
    opcode.call(inpa, inpb, outc, before.dup) == after
  }.map(&:first)
  [opcode, opnames]
end

known, programm = input.split("\n\n\n\n")
programms = known.split("\n\n")
part1 = programms.count { candidates(_1).last.count >= 3 }

dependencies = programms.inject({}) { |mapping, programm|
  opcode, options = candidates(programm)
  current_candidates = mapping[opcode] || options
  mapping.merge(opcode => current_candidates & options)
}.sort_by { _2.length }

mapping = {}
q = dependencies
while !q.empty? do
  code, matches = q.shift
  updated_matches = matches - mapping.values

  if updated_matches.count == 1
    mapping[code] = updated_matches.first
  else
    q << [code, updated_matches]
  end
end

result = programm.split("\n").map { _1.split(" ").map(&:to_i) }.inject([0, 0, 0, 0]) { |regs, inst|
  opcode, inpa, inpb, outc = inst
  INSTRUCTIONS.fetch(mapping.fetch(opcode)).call(inpa, inpb, outc, regs)
}
part2 = result[0]

p [part1, part2]
