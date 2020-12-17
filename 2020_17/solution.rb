require 'set'

ACTIVE = '#'

def neighbours(coordinates)
  coordinates
    .map { |i_dimension| [i_dimension - 1, i_dimension, i_dimension + 1] }
    .inject { |total, next_dimension| total.product(next_dimension) }
    .map(&:flatten)
    .reject { |neighbour| neighbour == coordinates }
end


def solve_cube(lines, iterations)
  current_generation = Set.new

  lines.size.times do |i|
    lines[0].size.times do |j|
      current_generation.add([0, i, j]) if lines[i][j] == ACTIVE
    end
  end

  iterations.times do
    next_generation = Set.new
    min, max = current_generation.flat_map(&:flatten).minmax
    field_range = Range.new(min - 1, max + 1)

    field_range.each do |z|
      field_range.each do |y|
        field_range.each do |x|
          active = neighbours([z, y, x]).count { |(nz, ny, nx)| current_generation.include?([nz, ny, nx]) }
          next_generation.add([z, y, x]) if active == 3 || (active == 2 && current_generation.include?([z, y, x]))
        end
      end
    end

    current_generation = next_generation
  end

  current_generation.size
end


def solve_hypercube(lines, iterations)
  current_generation = Set.new

  lines.size.times do |i|
    lines[0].size.times do |j|
      current_generation.add([0, 0, i, j]) if lines[i][j] == ACTIVE
    end
  end

  iterations.times do
    next_generation = Set.new
    min, max = current_generation.flat_map(&:flatten).minmax
    field_range = Range.new(min - 1, max + 1)

    field_range.each do |w|
      field_range.each do |z|
        field_range.each do |y|
          field_range.each do |x|
            active = neighbours([w, z, y, x]).count { |(nw, nz, ny, nx)| current_generation.include?([nw, nz, ny, nx]) }
            next_generation.add([w, z, y, x]) if active == 3 || (active == 2 && current_generation.include?([w, z, y, x]))
          end
        end
      end
    end

    current_generation = next_generation
  end

  current_generation.size
end

lines = File.read("input.txt").split("\n").map(&:chars)
puzzle1 = solve_cube(lines, 6)
puzzle2 = solve_hypercube(lines, 6)

p [puzzle1, puzzle2]
