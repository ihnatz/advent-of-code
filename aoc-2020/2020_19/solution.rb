input = File.read("input.txt")

rules, messages = input.split("\n\n")
messages = messages.split("\n")

def parse_description(desc)
  return [desc] if desc.size == 1 && desc.first.is_a?(Numeric)
  return desc   if desc.size == 1
  return [desc] unless desc.include?("|")
  return desc   if desc.size == 2

  if desc.size == 3
    [[desc[0]], [desc[-1]]]
  else
   [desc.slice(0, desc.index("|")), desc.slice(desc.index("|") + 1, desc.length)]
  end
end

preprocesed_rules =
  rules
    .split("\n")
    .map { _1.split(": ") }
    .map { |(idx, desc)| [idx, desc.split(" ")] }
    .map { |(idx, desc)| [idx, desc.map { _1.match?(/\d+/) ? _1.to_i : _1.delete('"') }] }
    .map { |(idx, desc)| [idx.to_i, parse_description(desc)] }
    .to_h


DEFAULT_FALSE = ->{false}
TERMINATED = preprocesed_rules.select { |idx, desc| desc[0].is_a?(String) }.map { [_1, _2[0]] }.to_h
GENERAL = preprocesed_rules.reject { TERMINATED.keys.include?(_1) }
TABLE = {}


def match_rest(string, rules)
  return true  if string.length == 0 && rules.empty?
  return false if string.length == 0 || rules.empty?

  x, *xs = *rules
  pairs = string.length.times.inject([]) { |result, i|
    result << [
      string.slice(0..i),
      string.slice((i + 1)..string.length)
    ]
  }

  pairs.find(DEFAULT_FALSE) do |left, right|
    match(left, x) && match_rest(right, Array(xs))
  end
end

def match(string, rule_idx)
  key = [string, rule_idx]
  return TABLE[key] if TABLE.has_key?(key)

  result = if TERMINATED.has_key?(rule_idx)
    string == TERMINATED[rule_idx]
  else
    GENERAL[rule_idx].find(DEFAULT_FALSE) do |rule|
      match_rest(string, rule)
    end
  end

  TABLE[key] = result
  result
end

puzzle1 = messages.count {
  TABLE.clear
  match(_1, 0)
}

GENERAL[8] = [[42], [42, 8]]
GENERAL[11] = [[42, 31], [42, 11, 31]]

puzzle2 = messages.count {
  TABLE.clear
  match(_1, 0)
}

p [puzzle1, puzzle2]
