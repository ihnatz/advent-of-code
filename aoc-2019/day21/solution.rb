require_relative './core.rb'

def print_blocks(blocks)
  blocks.each do |char_code|
    if char_code < 1000
      print char_code.chr
    else
      puts "*" * 80
      puts char_code
      puts "*" * 80
    end
  end
  puts
end

def to_code(input)
  (input + "\n").chars.map(&:ord)
end


def answer_1
  programm = [
  "NOT C T",
  "AND D T",
  "OR T J", # J = [!C && D]
  # ---------------------
  "NOT A T",
  "OR T J", # J || !A
  # ---------------------
  "WALK"
  ].join("\n")

  code = File.read('input.txt')
  core = Core.new(code, [])

  loop do
    break if core.halted
    core.run

    if core.awaiting_in
      core.input = to_code(programm)
      core.awaiting_in = false
    end
  end

  print_blocks(core.output.reverse)
end

def answer_2
  programm = [
    "NOT A J",
    "NOT B T",
    "OR J T",
    "NOT C J",
    "OR T J",  # [!A || !B || !C]
    # ---------------------
    "AND D J", # [&& D]
    # ---------------------
    "NOT E T", # T = !E
    "NOT T T", # T = !T = E
    "OR H T",  # T = E || H
    "AND T J", # [&& [E || H]]
    # # ---------------------
    "RUN"
  ].join("\n")

  code = File.read('input.txt')
  core = Core.new(code, [])

  loop do
    break if core.halted
    core.run

    if core.awaiting_in
      core.input = to_code(programm)
      core.awaiting_in = false
    end
  end
  print_blocks(core.output.reverse)
end

[answer_1, answer_2]
