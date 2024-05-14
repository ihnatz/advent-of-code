require 'set'

input = File.read("input.txt").split("\n")

DIRECTIONS = {
  'e'  => [2,0],
  'se' => [1,-2],
  'sw' => [-1, -2],
  'w'  => [-2, 0],
  'nw' => [-1, 2],
  'ne' => [1, 2],
}

def parse_line(line)
  result = []
  skip_next = false

  (line + "\t").chars.each_cons(2) { |pair|
    if skip_next
      skip_next = false
      next
    end

    if DIRECTIONS.keys.include?(pair.join)
      skip_next = true
      result << pair.join
    else
      result << pair[0]
    end
  }
  raise unless line == result.join
  result
end

flipped = Hash.new { 0 }

input.each do |line|
  directions = parse_line(line)
  result = directions.inject([0, 0]) { |final_coordinate, direction|
    [final_coordinate, DIRECTIONS[direction]].transpose.map(&:sum)
  }

  flipped[result] = !flipped[result]
end

def neighbours(x, y)
  DIRECTIONS.values.map do |nx, ny|
    [[x, y], [nx, ny]].transpose.map(&:sum)
  end
end

floor = flipped.select { _2 == false }
puzzle_1 = floor.count

current_generation = Set.new(flipped.select { _2 == false }.keys)

iterations = 100.times.map do |day|
  next_generation = Set.new
  min, max = current_generation.flat_map(&:flatten).minmax
  field_range = Range.new(min - 2, max + 2)

  field_range.each do |x|
    field_range.each do |y|
      black_tiles = neighbours(x, y).count { current_generation.include?(_1) }

      if current_generation.include?([x, y])
        # it's black!
        next_generation.add([x, y]) unless black_tiles == 0 || black_tiles > 2
      else
        # it's white
        next_generation.add([x, y]) if black_tiles == 2
      end
    end
  end

  current_generation = next_generation
  current_generation.count
end

puzzle_2 = iterations.last

p [puzzle_1, puzzle_2]
