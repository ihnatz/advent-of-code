data = File.read("input.txt").split("\n")

t2 = 0
t3 = 0

data.each do |line|
  gist = line.chars.tally
  t2 += 1 if gist.values.include?(2)
  t3 += 1 if gist.values.include?(3)
end

part1 = t2 * t3

part2 = nil

data.each do |line|
  data.each do |candidate|
    next if line == candidate
    diff = line.chars.zip(candidate.chars).map { _1 == _2 ? 0 : 1 }
    common = line.chars.zip(candidate.chars).map { _1 == _2 ? _1 : nil }.compact.join

    if diff.sum == 1
      part2 = common
      break
    end
  end
end

p [part1, part2]
