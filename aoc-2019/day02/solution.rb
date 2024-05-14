HALT = 99
INSTRUCTIONS = {
  1 => ->(memory, a, b, c) { memory[c] = memory[a] + memory[b] },
  2 => ->(memory, a, b, c) { memory[c] = memory[a] * memory[b] },
}

input = File.read('input.txt')
# input = "2,4,4,5,99,0"
# input = "1,9,10,3,2,3,11,0,99,30,40,50"

def run(memory)
  pointer = 0

  loop do
    opcode = memory[pointer]
    break if opcode == HALT

    command = INSTRUCTIONS[opcode]

    parameters = memory.slice((pointer + 1)..(pointer + command.arity - 1))
    command.call(memory, *parameters)
    pointer += command.arity

    # p memory; readline
  end

  memory
end

memory = input.split(",").map(&:to_i)
memory[1] = 12
memory[2] = 2
answer1 = run(memory)[0]

answer2 = nil
memory = input.split(",").map(&:to_i)

(0..99).each do |noun|
  (0..99).each do |verb|
    new_memory = memory.dup
    new_memory[1] = noun
    new_memory[2] = verb

    if run(new_memory)[0] == 19690720
      answer2 = 100 * noun + verb
      break
    end
  end
end

p [answer1, answer2]
