require 'set'

input = """
2199943210
3987894921
9856789892
8767896789
9899965678
""".strip

input = File.read("input.txt").strip

mapped = input.split("\n").map { |line|
  line.split("").map { |char| char.to_i }
}

agg = []
mapped.each_with_index do |line, i|
  line.each_with_index do |height, j|

    count = 0
    [[-1, 0], [0, -1], [1, 0], [0, 1]].each do |delta|
      x = j + delta[0]
      y = i + delta[1]

      count += 1 if mapped[y].nil? || mapped[y][x].nil?
      if x == -1 || y == -1
        count += 1
        next
      end

      if mapped[y] && mapped[y][x] && mapped[y][x] > height
        count += 1
      end
    end

    agg << ([j, i]) if count == 4

  end
end

answer1 = agg.map { |j, i| mapped[i][j] }.map { |x| x + 1 }.sum

def grow(x, y, mapped)
  stack = [[x, y]]
  visited = Set.new
  interested = Set.new
  count = 0

  while stack.any?
    sx, sy = stack.pop
    next if visited.include?([sx, sy])
    visited << [sx, sy]

    [[-1, 0], [0, -1], [1, 0], [0, 1]].each do |delta|
      x = sx + delta[0]
      y = sy + delta[1]

      next if mapped[y].nil? || mapped[y][x].nil? || x == -1 || y == -1
      if mapped[y][x] > mapped[sy][sx] && mapped[y][x] != 9
        stack << [x, y]
        interested << [x, y]
      end
    end
  end
  interested.count + 1
end


answer2 = agg.map { |x, y|
  grow(x, y, mapped)
}.sort.reverse.first(3).reduce(&:*)

p [answer1, answer2]
