require 'matrix'
require 'set'

input = """
1163751742
1381373672
2136511328
3694931569
7463417111
1319128137
1359912421
3125421639
1293138521
2311944581
""".strip

input = File.read("input.txt").strip
grid = input.split("\n").map { |l| l.chars.map(&:to_i) }

h_deep_grid = Matrix[*grid]

4.times do |i|
  grid_level = grid.map { |line|
    line.map { |value|
      if value + i + 1 > 9
        value + i - 8
      else
        value + i + 1
      end
    }
  }
  h_deep_grid = h_deep_grid.hstack(Matrix[*grid_level])
end

deep_grid = h_deep_grid.dup
h_deep_grid = h_deep_grid.to_a

4.times do |i|
  grid_level = h_deep_grid.map { |line|
    line.map { |value|
      if value + i + 1 > 9
        value + i - 8
      else
        value + i + 1
      end
    }
  }
  deep_grid = deep_grid.vstack(Matrix[*grid_level])
end

def pp(grid)
  grid.each do |line|
    puts line.map{|x| x.to_s.ljust(1)}.join("")
  end
  puts
end

def run(grid)
  queue = [[0, 0, 0]]
  visited = Set.new

  loop do
    y, x, path = queue.shift
    next if visited.include?([x, y])
    visited << [x, y]

    if x == grid.length - 1 && y == grid.length - 1
      return path
      break
    end

    [[0, -1], [-1, 0], [1, 0], [0, 1]].map { |dx, dy|
      new_x = x + dx
      new_y = y + dy
      next if new_x < 0 || new_x >= grid.length
      next if new_y < 0 || new_y >= grid.length

      queue << [new_y, new_x, path + grid[new_y][new_x]]
      queue.sort_by!(&:last) # missing heap :(
    }

    break if queue.empty?
  end
end

answer1 = run(grid)
answer2 = run(deep_grid.to_a)
p [answer1, answer2]
