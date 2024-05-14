class Rule
  def initialize(description)
    count, @letter = description.split(" ")
    @first, @last = count.split("-").map(&:to_i)
  end

  def old_rule_apply?(string)
    (@first..@last).include?(string.chars.count(@letter))
  end

  def new_rule_apply?(string)
    [string[@first - 1], string[@last - 1]].count(@letter) == 1
  end
end

passwords =
  File
    .read("input.txt")
    .split("\n")
    .map { |line| line.split(": ") }

puzzle1 = passwords.count { |(description, example)| Rule.new(description).old_rule_apply?(example) }
puzzle2 = passwords.count { |(description, example)| Rule.new(description).new_rule_apply?(example) }

p [puzzle1, puzzle2]
