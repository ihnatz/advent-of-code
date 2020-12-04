EXPECTED = 2020

input = File.read('input.txt')
numbers = input.split("\n").map(&:to_i).sort

puzzle1 = numbers.each do |current|
  companion = EXPECTED - current
  break(companion * current) if numbers.include?(companion)
end

puzzle2 = numbers.each do |current|
  resulted_companion = numbers.find do |companion|
    numbers.include?(EXPECTED - current - companion)
  end

  next unless resulted_companion

  num1 = current
  num2 = resulted_companion
  num3 = EXPECTED - num1 - num2

  break(num1 * num2 * num3)
end

p [puzzle1, puzzle2]
