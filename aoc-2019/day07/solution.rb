require './core'

def run_sequence(memory, sequence)
  current_boost = 0

  sequence.each do |amplifier|
    core = Core.new(memory, [amplifier, current_boost])
    core.run
    current_boost = core.output.last
  end

  current_boost
end

def run_sequence_rec(memory, sequence)
  core1 = Core.new(memory.clone, [sequence[0], 0])
  core2 = Core.new(memory.clone, [sequence[1], core1.run.first])
  core3 = Core.new(memory.clone, [sequence[2], core2.run.first])
  core4 = Core.new(memory.clone, [sequence[3], core3.run.first])
  core5 = Core.new(memory.clone, [sequence[4], core4.run.first])

  current_boost = core5.run.first

  amps = [core1, core2, core3, core4, core5]
  while amps.none?(&:halted)
    amps.each do |amp|
      amp.input = [current_boost]
      result = amp.run
      current_boost = result.first if result
    end
  end

  current_boost
end

memory = File.read('input.txt')
answer1 = (0..4).to_a.permutation.to_a.map { |sequence| run_sequence(memory, sequence) }.max
answer2 = (5..9).to_a.permutation.to_a.map { |sequence| run_sequence_rec(memory, sequence) }.max
p [answer1, answer2]
