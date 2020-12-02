EXPECTED = 2020

input = File.read('in.txt')
numbers = input.split("\n").map(&:to_i).sort

numbers.each do |current|
  resulted_companion = numbers.find do |companion|
    break if current + companion > EXPECTED
    numbers.include?(EXPECTED - current - companion)
  end

  if resulted_companion
    num1 = current
    num2 = resulted_companion
    num3 = EXPECTED - num1 - num2

    p [num1, num2, num3, num1 * num2 * num3]

    break
  end
end
