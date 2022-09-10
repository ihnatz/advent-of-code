coordinates = File.read("input.txt").split("\n").map { _1.split(", ").map(&:to_i) }

max_x = coordinates.map(&:first).max + 1
max_y = coordinates.map(&:last).max + 1

space = Array.new(max_y + 1) { Array.new(max_x + 1) { nil } }

stars = {}
coordinates.each_with_index { |(x, y), idx|
  stars[[x, y]] = idx
}

def mdist(x1, y1, x2, y2)
  (x1 - x2).abs + (y1 - y2).abs
end

(0..max_x).each do |x|
  (0..max_y).each do |y|
    if stars[[x, y]]
      space[y][x] = stars[[x, y]]
      next
    end

    distances = {}
    coordinates.each do |(x1, y1)|
      distance = mdist(x1, y1, x, y)
      distances[distance] ||= []
      distances[distance] << [x1, y1]
    end

    min = distances.keys.min
    equals = distances[min].count > 1
    closest = stars[distances[min].first]

    space[y][x] = equals ? '.' : closest
  end
end

infs = (space.first + space.map(&:last) + space.map(&:first) + space.last).uniq
part1 = space.flatten.tally.reject { |k, v| infs.include?(k) }.values.max

# ------------------------------------------------------------------------------

counter = 0
(0..max_x).each do |x|
  (0..max_y).each do |y|

    points = {}
    coordinates.each do |(x1, y1)|
      distance = mdist(x1, y1, x, y)
      points[[x, y]] ||= []
      points[[x, y]] << distance
    end

    counter += 1 if points[[x, y]].sum < 10_000
  end
end
part2 = counter

p [part1, part2]
