class Rule
  def initialize(description)
    count, @letter = description.split(" ")
    @first, @last = count.split("-").map(&:to_i)
  end

  def apply?(string)
    [string[@first - 1], string[@last - 1]].count(@letter) == 1
  end
end

result = File.read("in.txt").split("\n").select do |line|
  description, example = line.split(": ")
  Rule.new(description).apply?(example)
end.count

p result
