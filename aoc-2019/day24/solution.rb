require 'json'

example = "
....#
#..#.
#..##
..#..
#....
"

input = "
#....
#...#
##.##
....#
#.##.
"

BUG = 1
EMPTY = 0

def neighbours(coordinates)
  [
    [0, 1],
    [0, -1],
    [1, 0],
    [-1, 0]
  ].map { |(off_x, off_y)| [coordinates[0] + off_x, coordinates[1] + off_y] }
end


def biodiversity(generation)
  generation.each_with_index.map do |(key, value), idx|
    value == BUG ? 2 ** idx : 0
  end.sum
end

def answer_1(input)
  biodiversities = []
  this_generation = {}
  next_generation = {}
  grid = input.strip.split("\n").map(&:chars)
  grid.each_with_index do |row, y|
    row.each_with_index do |value, x|
      next_generation[[x, y]] = value == ?# ? BUG : EMPTY
    end
  end

  loop {
    this_generation = next_generation.dup

    this_generation.each do |(x, y), type|
      bugs_count = neighbours([x, y])
        .map { |coordinate| this_generation[coordinate] }
        .compact
        .group_by(&:itself)
        .transform_values(&:count)[BUG]

      next_generation[[x, y]] = if type == BUG && bugs_count != 1
        EMPTY
      elsif type == EMPTY && [1,2].include?(bugs_count)
        BUG
      else
        type
      end
    end

    new_value = biodiversity(next_generation)
    break(new_value) if biodiversities.include?(new_value)
    biodiversities << new_value
  }
end

MIDDLE = [2, 2]

def recursive_neighbors(coordinates, level)
  result = []
  directions = [
    [0, 1],  # down
    [0, -1], # up
    [1, 0],  # right
    [-1, 0]  # left
  ]
  directions.map { |(off_x, off_y)| [coordinates[0] + off_x, coordinates[1] + off_y] }
   .zip(directions)
   .map { |(new_x, new_y), offset|
    if [new_x, new_y] == MIDDLE
      case offset
      when [0, -1] then result += (0..4).map { |i| [i, 4, level + 1] }
      when [-1, 0] then result += (0..4).map { |i| [4, i, level + 1] }
      when [0, 1]  then result += (0..4).map { |i| [i, 0, level + 1] }
      when [1, 0]  then result += (0..4).map { |i| [0, i, level + 1] }
      end
    elsif new_y == -1
      result << [2, 1, level - 1]
    elsif new_y == 5
      result << [2, 3, level - 1]
    elsif new_x == -1
      result << [1, 2, level - 1]
    elsif new_x == 5
      result << [3, 2, level - 1]
    else
      result << [new_x, new_y, level]
    end
  }
  result
end

EMPTY_MAP = {}
(0..4).each { |i| (0..4).each { |j| EMPTY_MAP[[i, j]] = EMPTY } }

def answer_2(input)
  next_generation = { -1 => EMPTY_MAP.dup, 0 => EMPTY_MAP.dup, 1 => EMPTY_MAP.dup }
  grid = input.strip.split("\n").map(&:chars)
  grid.each_with_index do |row, y|
    row.each_with_index do |value, x|
      next_generation[0][[x, y]] = value == ?# ? BUG : EMPTY
    end
  end

  200.times { |i|
    temp = Marshal.dump(next_generation)
    this_generation = Marshal.load(temp)

    this_generation.each do |level, grid|
      grid.each do |(x, y), type|
        bugs_count = recursive_neighbors([x, y], level)
          .map { |(nx, ny, on_level)|
            next_generation[on_level] ||= EMPTY_MAP.dup.map(&:dup).to_h
            this_generation[on_level].to_h[[nx, ny]]
          }
          .compact
          .group_by(&:itself)
          .transform_values(&:count)[BUG]

        bugs_count = 0 if [x, y] == MIDDLE

        next_generation[level][[x, y]] = if type == BUG && bugs_count != 1
          EMPTY
        elsif type == EMPTY && [1,2].include?(bugs_count)
          BUG
        else
          type
        end
      end
    end
  }

  next_generation.values.map(&:values).flatten.sum
end

p [answer_1(input), answer_2(input)]
