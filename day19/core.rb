module Commands
  MAPPING = {
    1 => :add,
    2 => :mul,
    3 => :in,
    4 => :out,
    5 => :jnz,
    6 => :jz,
    7 => :flz,
    8 => :feq,
    9 => :adj
  }

  def adj(modes, a)
    @relative_base += to_arg(modes[0], a)
    @pointer + 2
  end

  def add(modes, a, b, c)
    require 'pry'; binding.pry if to_arg(modes[1], b).nil?
    @memory[to_ref(modes[2], c)] = to_arg(modes[0], a) + to_arg(modes[1], b)
    @pointer + 4
  end

  def mul(modes, a, b, c)
    @memory[to_ref(modes[2], c)] = to_arg(modes[0], a) * to_arg(modes[1], b)
    @pointer + 4
  end

  def in(modes, a)
    value = @input.shift
    raise "Input value expected" unless value
    @memory[to_ref(modes[0], a)] = value
    @pointer + 2
  end

  def out(modes, a)
    value = to_arg(modes[0], a)
    @awaiting = @output.unshift(value)
    @pointer + 2
  end

  def jnz(modes, a, b)
    to_arg(modes[0], a) != 0 ? to_arg(modes[1], b) : @pointer + 3
  end

  def jz(modes, a, b)
    to_arg(modes[0], a) == 0 ? to_arg(modes[1], b) : @pointer + 3
  end

  def flz(modes, a, b, c)
    @memory[to_ref(modes[2], c)] = to_arg(modes[0], a) < to_arg(modes[1], b) ? 1 : 0
    @pointer + 4
  end

  def feq(modes, a, b, c)
    @memory[to_ref(modes[2], c)] = to_arg(modes[0], a) == to_arg(modes[1], b) ? 1 : 0
    @pointer + 4
  end

  private

  def to_ref(mode, address)
    case mode
    when 1 then address
    when 2 then @relative_base + address
    when 0 then address
    end
  end

  def to_arg(mode, address)
    case mode
    when 1 then address
    when 2 then @memory.fetch(address + @relative_base, 0) || 0
    when 0 then @memory.fetch(address, 0) || 0
    end
  end
end

class Core
  include Commands

  HALT = 99

  attr_reader :output, :halted, :memory
  attr_accessor :input, :awaiting_in

  def initialize(memory, input)
    @memory = memory.split(",").map(&:to_i)
    @input = input
    @output = []
    @pointer = 0
    @halted = false
    @awaiting = false
    @awaiting_in = false

    @relative_base = 0
  end

  def run
    loop do
      raw_code = @memory[@pointer]

      if raw_code == 3 && @input.empty?
        @awaiting_in = true
        break
      end

      if @awaiting
        temp = @awaiting
        @awaiting = false
        return temp
      end

      if raw_code == HALT
        @halted = true
        break
      end

      opcode, modes = args_parser(raw_code)
      command = method(MAPPING[opcode])
      parameters = @memory.slice((@pointer + 1)..(@pointer + command.arity - 1))
      shift = command.call(modes, *parameters)
      @pointer = shift
    end
  end

  def args_parser(value)
    opcode = value.digits.reverse.last(2).join.to_i
    modes = value.digits.reverse.slice(0..-3)
    modes_count = method(MAPPING[opcode]).arity - 1
    all_modes = [0] * (modes_count - modes.length) + modes

    [opcode, all_modes.reverse]
  end
end

def check_sequence
  test = "3,225,1,225,6,6,1100,1,238,225,104,0,1101,65,73,225,1101,37,7,225,1101,42,58,225,1102,62,44,224,101,-2728,224,224,4,224,102,8,223,223,101,6,224,224,1,223,224,223,1,69,126,224,101,-92,224,224,4,224,1002,223,8,223,101,7,224,224,1,223,224,223,1102,41,84,225,1001,22,92,224,101,-150,224,224,4,224,102,8,223,223,101,3,224,224,1,224,223,223,1101,80,65,225,1101,32,13,224,101,-45,224,224,4,224,102,8,223,223,101,1,224,224,1,224,223,223,1101,21,18,225,1102,5,51,225,2,17,14,224,1001,224,-2701,224,4,224,1002,223,8,223,101,4,224,224,1,223,224,223,101,68,95,224,101,-148,224,224,4,224,1002,223,8,223,101,1,224,224,1,223,224,223,1102,12,22,225,102,58,173,224,1001,224,-696,224,4,224,1002,223,8,223,1001,224,6,224,1,223,224,223,1002,121,62,224,1001,224,-1302,224,4,224,1002,223,8,223,101,4,224,224,1,223,224,223,4,223,99,0,0,0,677,0,0,0,0,0,0,0,0,0,0,0,1105,0,99999,1105,227,247,1105,1,99999,1005,227,99999,1005,0,256,1105,1,99999,1106,227,99999,1106,0,265,1105,1,99999,1006,0,99999,1006,227,274,1105,1,99999,1105,1,280,1105,1,99999,1,225,225,225,1101,294,0,0,105,1,0,1105,1,99999,1106,0,300,1105,1,99999,1,225,225,225,1101,314,0,0,106,0,0,1105,1,99999,1008,226,677,224,102,2,223,223,1005,224,329,1001,223,1,223,7,677,226,224,102,2,223,223,1006,224,344,1001,223,1,223,1007,226,677,224,1002,223,2,223,1006,224,359,1001,223,1,223,1007,677,677,224,102,2,223,223,1005,224,374,1001,223,1,223,108,677,677,224,102,2,223,223,1006,224,389,101,1,223,223,8,226,677,224,102,2,223,223,1005,224,404,101,1,223,223,7,226,677,224,1002,223,2,223,1005,224,419,101,1,223,223,8,677,226,224,1002,223,2,223,1005,224,434,101,1,223,223,107,677,677,224,1002,223,2,223,1006,224,449,101,1,223,223,7,677,677,224,1002,223,2,223,1006,224,464,101,1,223,223,1107,226,226,224,102,2,223,223,1006,224,479,1001,223,1,223,1007,226,226,224,102,2,223,223,1006,224,494,101,1,223,223,108,226,677,224,1002,223,2,223,1006,224,509,101,1,223,223,1108,226,677,224,102,2,223,223,1006,224,524,1001,223,1,223,1008,226,226,224,1002,223,2,223,1005,224,539,101,1,223,223,107,226,226,224,102,2,223,223,1006,224,554,101,1,223,223,8,677,677,224,102,2,223,223,1005,224,569,101,1,223,223,107,226,677,224,102,2,223,223,1005,224,584,101,1,223,223,1108,226,226,224,1002,223,2,223,1005,224,599,1001,223,1,223,1008,677,677,224,1002,223,2,223,1005,224,614,101,1,223,223,1107,226,677,224,102,2,223,223,1005,224,629,101,1,223,223,1108,677,226,224,1002,223,2,223,1005,224,644,1001,223,1,223,1107,677,226,224,1002,223,2,223,1006,224,659,1001,223,1,223,108,226,226,224,102,2,223,223,1006,224,674,101,1,223,223,4,223,99,226"
  input = [1]
  outputs = []
  core = Core.new(test, input)

  result = nil

  loop do
    core_result = core.run
    break if core.halted
    result = core_result
  end

  raise unless result.first == 14522484
  raise unless result.slice(1..).all?(&:zero?)
  puts 'ok'
end

check_sequence if ENV["CHECK"]
