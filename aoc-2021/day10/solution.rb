input = """
[({(<(())[]>[[{[]{<()<>>
[(()[<>])]({[<{<<[]>>(
{([(<{}[<>[]}>{[]{[(<()>
(((({<>}<{<{<>}{[]{[]{}
[[<[([]))<([[{}[[()]]]
[{[{({}]{}}([{[{{{}}([]
{<[[]]>}<{[{[{[]{()[[[]
[<(<(<(<{}))><([]([]()
<{([([[(<>()){}]>(<<{{
<{([{{}}[<[[[<>{}]]]>[]]
""".strip

input = File.read('input.txt').strip

POINTS = {
  ")" => 3,
  "]" => 57,
  "}" => 1197,
  ">" => 25137
}

OPOS = {
  ")" => "(",
  "]" => "[",
  "}" => "{",
  ">" => "<"
}

OOPOS = {
   "(" => ")",
   "[" => "]",
   "{" => "}",
   "<" => ">"
}

def balanced?(str)
  stack = []
  str.each_char do |c|
    case c
    when "(", "[", "{", "<"
      stack << c
    when ")", "]", "}", ">"
      return c unless stack.pop == OPOS[c]
    end
  end
  ""
end

def missing_balance(str)
  stack = []
  str.each_char do |c|
    case c
    when "(", "[", "{", "<"
      stack << c
    when ")", "]", "}", ">"
      return c unless stack.pop == OPOS[c]
    end
  end
  stack.map { |c| OOPOS[c] }.reverse.join
end

answer1 = input.split("\n").map { |line|
  balanced?(line)
}.reject(&:empty?).map { |char| POINTS[char] }.reduce(:+)

NEW_POINTS = {
  ")" => 1,
  "]" => 2,
  "}" => 3,
  ">" => 4,
}

def to_i(str)
  str.chars.map { |char| NEW_POINTS[char] }.join.to_i(5)
end

sorted = input.split("\n").select { |line|
  balanced?(line) == ""
}.map { |line|
  to_i(missing_balance(line))
}.sort

answer2 = sorted[sorted.length / 2]

p [answer1, answer2]
