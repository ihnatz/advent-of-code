input = File
    .read("input.txt")
    .split("\n")
    .map { |line| line.scan(/position=<(.+),(.+)> velocity=<(.+),(.+)>/).first }
    .map { _1.map(&:to_i) }

def print_points(points)
  min_x, max_x = points.map(&:first).minmax
  min_y, max_y = points.map(&:last).minmax

  (min_y..max_y).each do |y|
    (min_x..max_x).each do |x|
      char = if points.include?([x, y])
        '#'
      else
        '.'
      end
      print char
    end
    puts
  end
end

def area_for(generation)
  min_x, max_x = generation.map(&:first).minmax
  min_y, max_y = generation.map(&:last).minmax
  (max_x - min_x) * (max_y - min_y)
end

generation = input.map { _1.first(2) }
velocities = input.map { _1.last(2) }

area = nil
prev_generation = nil

20_000.times do |i|
  new_generation = generation.zip(velocities).map { |(x, y), (dx, dy)|
    [x + dx * i, y + dy * i]
  }
  new_area = area_for(new_generation)

  if area && area < new_area
    p i - 1
    print_points(prev_generation)
    break
  else
    area = new_area
    prev_generation = new_generation
  end
end
