input = """
16,1,2,0,4,2,7,1,2,14
""".strip
input = File.read("input.txt")

heights = input.split(",").map(&:to_i)
median = input.split(",").map(&:to_i).sort[heights.length / 2]
answer1 = heights.map { |height| (height - median).abs }.sum

def cost(from, to)
  from, to = to, from if from > to
  (2 * 1 + 1 * (to - from - 1)) / 2.0 * (to - from )
end

average = input.split(",").map(&:to_i).sum / heights.length
answer2 = heights.map { |height| cost(height, average) }.sum.to_i

p [answer1, answer2]
