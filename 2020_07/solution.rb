class ColorDescription
  Rule = Struct.new(:quantity, :color_name)
  attr_reader :color_name
  attr_reader :rules

  def initialize(color_name)
    @color_name = color_name
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

def build_mapping(descriptions)
  descriptions.inject({}) do |mapping, (color_name, content)|
    color_rules = mapping.fetch(color_name) { mapping[color_name] = ColorDescription.new(color_name) }

    content.each do |(count, rule_color_name)|
      mapping[rule_color_name] ||= ColorDescription.new(rule_color_name)
      mapping[color_name].push(count, rule_color_name)
    end

    mapping
  end
end

EXPECTED_COLOR = 'shiny gold'
MAPPING = build_mapping(descriptions)

def can_contain_color?(color_name)
  color = MAPPING[color_name]
  return true if color.color_name == EXPECTED_COLOR
  return color.rules.any? { |rule| can_contain_color?(rule.color_name) }
end

def count_bags_for(color_name, total = 0)
  color = MAPPING[color_name]
  return 0 if color.rules.empty?

  this_color_bags_inside = color.rules.sum do |rule|
    rule.quantity * count_bags_for(rule.color_name)
  end
  this_color_bags_itself = color.rules.sum(&:quantity)

  [total, this_color_bags_inside, this_color_bags_itself].sum
end

puzzle1 = MAPPING.values.count do |color_description|
  color_description.rules.any? { |rule| can_contain_color?(rule.color_name) }
end
puzzle2 = count_bags_for(EXPECTED_COLOR)

p [puzzle1, puzzle2]
