MAX_SPOKEN_EASY = 2020
MAX_SPOKEN_HARD = 30000000

numbers = File.read("input.txt").split(",").map(&:to_i)

progression = numbers
spoken = Hash.new { [0, 0] }
numbers.each_with_index { |new_number, step| spoken[new_number] = [step + 1, 0] }
step = progression.length + 1

while step <= MAX_SPOKEN_HARD
  last_number_spoken = progression.last
  first_time_spoken = spoken[last_number_spoken].last == 0

  new_number = first_time_spoken ? 0 : spoken[last_number_spoken].inject(&:-)

  progression << new_number
  spoken[new_number] = [step, spoken[new_number].first]

  puzzle1 = new_number if step == MAX_SPOKEN_EASY

  step += 1
end

puzzle2 = progression.last
p [puzzle1, puzzle2]
