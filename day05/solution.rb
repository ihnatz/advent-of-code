HALT = 99

def to_arg(memory, mode, code)
  mode == 1 ? code : memory.fetch(code)
end

INSTRUCTIONS = {
  1 => ->(pos, modes, memory, a, b, c) {
    memory[c] =
      to_arg(memory, modes[0], a) +
      to_arg(memory, modes[1], b);
    pos + 4
  },
  2 => ->(pos, modes, memory, a, b, c) {
    memory[c] =
      to_arg(memory, modes[0], a) *
      to_arg(memory, modes[1], b);
    pos + 4
  },
  3 => ->(pos, modes, memory, a) {
    memory[a] = readline.to_i;
    pos + 2
  },
  4 => ->(pos, modes, memory, a) {
    puts to_arg(memory, modes[0], a);
    pos + 2
  },
  5 => ->(pos, modes, memory, a, b) {
    to_arg(memory, modes[0], a) != 0 ?
      to_arg(memory, modes[1], b) :
      pos + 3
  },
  6 => ->(pos, modes, memory, a, b) {
    to_arg(memory, modes[0], a) == 0 ?
      to_arg(memory, modes[1], b) :
      pos + 3
  },
  7 => ->(pos, modes, memory, a, b, c) {
    memory[c] = to_arg(memory, modes[0], a) < to_arg(memory, modes[1], b) ?
      1 :
      0;
    pos + 4
  },
  8 => ->(pos, modes, memory, a, b, c) {
    memory[c] = to_arg(memory, modes[0], a) == to_arg(memory, modes[1], b) ?
    1 :
    0;
    pos + 4
  },
}

input = File.read('input.txt')
# input = "1,1,1,4,99,5,6,0,99"
# input = "1002,4,3,4,33"
# input = "1101,100,-1,4,0"
# input = "3,9,8,9,10,9,4,9,99,-1,8"
# input = "3,9,7,9,10,9,4,9,99,-1,8"
# input = "3,3,1107,-1,8,3,4,3,99"
# input = "3,12,6,12,15,1,13,14,13,4,13,99,-1,0,1,9"
# input = "3,3,1105,-1,9,1101,0,0,12,4,12,99,1"
# input = "3,21,1008,21,8,20,1005,20,22,107,8,21,20,1006,20,31,1106,0,36,98,0,0,1002,21,125,20,4,20,1105,1,46,104,999,1105,1,46,1101,1000,1,20,4,20,1105,1,46,98,99"

def run(memory)
  pointer = 0

  loop do
    raw_code = memory[pointer]
    break if raw_code == HALT

    opcode, modes = args_parser(raw_code)

    command = INSTRUCTIONS[opcode]
    parameters = memory.slice((pointer + 1)..(pointer + command.arity - 3))

    shift = command.call(pointer, modes, memory, *parameters)

    pointer = shift
  end

  memory
end

def args_parser(value)
  opcode = value.digits.reverse.last(2).join.to_i
  modes = value.digits.reverse.slice(0..-3)

  modes_count = INSTRUCTIONS[opcode].arity - 3
  all_modes = [0] * (modes_count - modes.length) + modes

  [opcode, all_modes.reverse]
end

memory = input.split(",").map(&:to_i)
p run(memory)
