EXPECTED = 2020

input = File.read('in.txt')
numbers = input.split("\n").map(&:to_i)

result = numbers.find do |current|
  companion = EXPECTED - current
  numbers.include?(companion)
end

num1 = result
num2 = EXPECTED - result

p [num1, num2, num1 * num2]
