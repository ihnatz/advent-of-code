input = File.read('input.txt').split("\n").map(&:to_i).sort
MAX_STEP = 3

current_voltage = 0
count_1_jolt = 0
count_3_jolt = 0

input << input.max + MAX_STEP

loop do
  current_step = (1..MAX_STEP).find { |step| input.include?(current_voltage + step) }
  current_voltage += current_step

  case current_step
  when 1 then count_1_jolt += 1
  when 3 then count_3_jolt += 1
  end

  break if current_voltage == input.max
end

puzzle1 = count_1_jolt * count_3_jolt


input = [0] + input
traces = Array.new(input.length, 0)
traces[0] = 1

input.each_with_index do |current_voltage, current_index|
  (1..MAX_STEP).each do |step|
    prev_voltage = current_voltage - step
    if input.include?(prev_voltage)
      prev_index = input.index(prev_voltage)
      traces[current_index] += traces[prev_index]
    end
  end
end

puzzle2 = traces.last

p [puzzle1, puzzle2]
