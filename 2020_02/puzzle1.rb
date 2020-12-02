class Rule
  def initialize(description)
    count, @letter = description.split(" ")
    @min, @max = count.split("-").map(&:to_i)
  end

  def apply?(string)
    (@min..@max).include?(string.chars.count(@letter))
  end
end

result = File.read("in.txt").split("\n").select do |line|
  description, example = line.split(": ")
  Rule.new(description).apply?(example)
end.count

p result
