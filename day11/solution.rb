N = 300
WINDOW = 3
SERIAL_NUMBER = 9221

def power(x, y, serial_number)
  rack_id = x + 10
  (rack_id * y + serial_number) * rack_id / 100 % 10 - 5
end

# p power(3, 5, 8)      #  4
# p power(122, 79, 57)  # -5
# p power(217, 196, 39) #  0
# p power(101, 153, 71) #  4

def generate_grid(serial_number)
  grid = Array.new(N + 1) { Array.new(N + 1) }

  (0..N).each do |y|
    (0..N).each do |x|
      grid[y][x] = power(x, y, serial_number)
    end
  end

  grid
end

def cap(value, min, max)
  return max if value > max
  return min if value < min
  value
end

def summed_area_table(grid)
  max_x = grid.first.count
  max_y = grid.count

  table = Array.new(max_y) { Array.new(max_x, 0) }
  (0...max_y).each do |y|
    (0...max_x).each do |x|
      table[y][x] = case
        when x == 0 && y == 0 then grid[y][x]
        when x == 0 && y > 0 then grid[y][x] + table[y - 1][x]
        when y == 0 && x > 0 then grid[y][x] + table[y][x - 1]
        else grid[y][x] + table[y - 1][x] + table[y][x - 1] - table[y - 1][x - 1]
      end
    end
  end
  table
end

def area_sum(table, x, y, window)
  dx = window
  dy = window
  a = table[y - 1][x - 1]
  b = table[y - 1][x - 1 + dx]
  c = table[y - 1 + dy][x - 1]
  d = table[y - 1 + dy][x - 1 + dx]

  d - b - c + a
end

grid = generate_grid(SERIAL_NUMBER)
table = summed_area_table(grid)

result = []
(1..N).each do |y|
  (1..N).each do |x|
    next if x + WINDOW >= N
    next if y + WINDOW >= N
    result << [x, y, WINDOW, area_sum(table, x, y, WINDOW)]
  end
end
part1 = result.max_by(&:last).first(2).join(",")

result = []
(1..N).each do |y|
  (1..N).each do |x|
    (1..N).each do |window|
      next if x + window >= N
      next if y + window >= N
      result << [x, y, window, area_sum(table, x, y, window)]
    end
  end
end

part2 = result.max_by(&:last).first(3).join(",")

p [part1, part2]
