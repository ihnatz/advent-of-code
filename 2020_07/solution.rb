class Bag
  Rule = Struct.new(:quantity, :color)
  attr_reader :color
  attr_reader :rules

  def initialize(color)
    @color = color
    @rules = []
  end

  def push(count, new_color)
    @rules << Rule.new(count, new_color)
  end
end

descriptions = File
  .read('input.txt')
  .split("\n")
  .map { _1.split(" contain ") }
  .map { [_1.gsub(/ bags/, ''), _2.split(/[,.]\s?/)] }
  .map { [_1, _2 == ["no other bags"] ? [] : _2] }
  .map { [_1, _2.map { |desc| desc.gsub(/ bags?/, '') }] }
  .map { [_1, _2.map { |desc| desc.split(' ', 2)}] }
  .map { [_1, _2.map { |(count, color)| [count.to_i, color] }]}

MAPPING = {}
descriptions.each do |color, content|
  if MAPPING[color].nil?
    MAPPING[color] = Bag.new(color)
  end
  color_rules = MAPPING[color]

  content.each do |(count, rule_color)|
    if MAPPING[rule_color].nil?
      MAPPING[rule_color] = Bag.new(rule_color)
    end
    MAPPING[color].push(count, rule_color)
  end
end

def traverse_color(color_name)
  color = MAPPING[color_name]
  return true if color.color == "shiny gold"
  return true if color.rules.any? { |rule| rule.color == "shiny gold" }
  return false if color.rules.empty?
  return color.rules.any? { |rule| traverse_color(rule.color) }
end

puzzle1 = MAPPING.count do |color_name, color_description|
  color_description.rules.any? { |rule| traverse_color(rule.color) }
end

def deep_traverse(color_name, total = 0)
  color = MAPPING[color_name]
  return 0 if color.rules.empty?

  this_color_count = color.rules.sum do |rule|
    rule.quantity * deep_traverse(rule.color)
  end
  total + this_color_count + color.rules.sum(&:quantity)
end

puzzle2 = deep_traverse('shiny gold')

p [puzzle1, puzzle2]
