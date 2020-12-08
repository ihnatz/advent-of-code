input = File.read('input.txt')

commands =
  input
    .split("\n")
    .map { |command| command.split(' ') }
    .map { |(instruction, value)| [instruction, value.to_i] }

def run(commands)
  acc = 0
  cursor = 0
  calls_tracker = Array.new(commands.length, 0)

  halted = loop {
    instruction, value = commands[cursor]
    calls_tracker[cursor] += 1

    break false if calls_tracker.any? { _1 > 1 }

    case instruction
    when 'nop'
      cursor += 1
    when 'acc'
      acc += value
      cursor += 1
    when 'jmp'
      cursor += value
    end

    break true if cursor == commands.length
  }

  [halted, acc]
end

_, puzzle1 = run(commands)

puzzle2 = commands.each_with_index { |(instruction, value), index|
  alternative = case instruction
  when 'nop' then 'jmp'
  when 'jmp' then 'nop'
  else next
  end

  alternative_commands = commands.dup
  alternative_commands[index] = [alternative, value]

  halted, result = run(alternative_commands)

  break result if halted
}

p [puzzle1, puzzle2]
