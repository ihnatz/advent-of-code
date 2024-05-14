input = """
NNCB

CH -> B
HH -> N
CB -> H
NH -> C
HB -> C
HC -> B
HN -> C
NN -> C
BH -> H
NC -> B
NB -> B
BN -> B
BB -> N
BC -> B
CC -> N
CN -> C
""".strip

input = File.read("input.txt").strip

N1 = 10
N2 = 40


template, rules = input.split("\n\n")
rules = rules.split("\n").map { |rule| rule.split(" -> ") }.to_h
N1.times { |i|
  template = template.chars.each_cons(2).map { |(a, b)| a + rules[a + b] }.join + template.chars.last
}

answer1 = template.chars.tally.values.minmax.reduce(:-).abs

template, _ = input.split("\n\n")
pairs = template.chars.each_cons(2).to_a

pairs_dict = pairs.each_with_object(Hash.new(0)) { |pair, total| total[pair.join] += 1 }

N2.times do
  new_pairs = Hash.new(0)
  pairs_dict.each do |pair, count|
    new_letter = rules[pair]
    new_pairs[pair[0] + new_letter] += count
    new_pairs[new_letter + pair[1]] += count
  end

  pairs_dict = new_pairs
end

total = Hash.new(0)
pairs_dict.each do |pair, value|
  a, b = pair.chars
  total[a] += value / 2.0
  total[b] += value / 2.0
end

total.transform_values!(&:round)
answer2 = total.values.minmax.reduce(:-).abs

p [answer1, answer2]
