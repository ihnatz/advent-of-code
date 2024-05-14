input = "
be cfbegad cbdgef fgaecd cgeb fdcge agebfd fecdb fabcd edb | fdgacbe cefdb cefbgd gcbe
edbfga begcd cbg gc gcadebf fbgde acbgfd abcde gfcbed gfec | fcgedb cgb dgebacf gc
fgaebd cg bdaec gdafb agbcfd gdcbef bgcad gfac gcb cdgabef | cg cg fdcagb cbg
fbegcd cbd adcefb dageb afcb bc aefdc ecdab fgdeca fcdbega | efabcd cedba gadfec cb
aecbfdg fbg gf bafeg dbefa fcge gcbea fcaegb dgceab fcbdga | gecf egdcabf bgf bfgea
fgeab ca afcebg bdacfeg cfaedg gcfdb baec bfadeg bafgc acf | gebdcfa ecba ca fadegcb
dbcfg fgd bdegcaf fgec aegbdf ecdfab fbedc dacgb gdcebf gf | cefg dcbef fcge gbcadfe
bdfegc cbegaf gecbf dfcage bdacg ed bedf ced adcbefg gebcd | ed bcgafe cdgba cbgef
egadfb cdbfeg cegd fecab cgb gbdefca cg fgcdab egfdb bfceg | gbdfcae bgc cg cgb
gcafb gcf dcaebfg ecagb gf abcdeg gaef cafbge fdbac fegbdc | fgae cfgab fg bagce
".strip

input = File.read("input.txt").strip

DIGITS = {
  1 => 2,
  4 => 4,
  7 => 3,
  8 => 7
}

RE_DIGITS = {
   2 => 1,
   4 => 4,
   3 => 7,
   7 => 8
}

answer1 = input.split("\n").map { |line|
  _desc, digits = line.split('|')
  digits.split.map(&:length).select { |x| DIGITS.values.include?(x) }.count
}.sum

answer2 = input.split("\n").map { |line|
  all_digits, display = line.split(' | ')
  all_digits = all_digits.split(" ")
  mapping = []
  all_digits.each_with_index do |digit, index|
    if RE_DIGITS.include?(digit.length)
      mapping[RE_DIGITS[digit.length]] = digit
    end
  end

  missing = (all_digits - mapping.compact)
  nine = missing.select { |x| x.length == 6 }.find { |x| (x.chars & mapping[4].chars).length == 4 }
  raise if nine.nil?
  mapping[9] = nine
  missing.delete(nine)

  six_zero = missing.select { |x| x.length == 6 } - [nine]
  missing = missing - six_zero

  common = missing.map { |x| x.chars.sort }.reduce(&:&)
  three = missing.find { |x| (x.chars - common - mapping[1].chars).empty? }
  raise if three.nil?
  mapping[3] = three
  missing.delete(three)

  zero = six_zero.find { |x| (x.chars & mapping[1].chars).length == 2 }
  raise if zero.nil?
  six = (six_zero - [zero]).first
  mapping[0] = zero
  mapping[6] = six

  five = missing.find { |x| (x.chars & mapping[6].chars).length == 5 }
  raise if five.nil?
  two = (missing - [five]).first
  mapping[2] = two
  mapping[5] = five

  mapping.map! { |x| x.chars.sort.join }

  result = display.strip.split(" ").map { |x| mapping.index(x.chars.sort.join) }.join.to_i
}.sum

p [answer1, answer2]
