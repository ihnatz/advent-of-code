input = if true
  File.read('input.txt')
else
  File.read('sample.txt')
end.strip

def pp(grid)
  grid.each do |line|
    puts line.join
  end
  puts
end

grid = input.split("\n").map(&:chars)

def step(grid)
  new_grid = grid.map { _1.map { "." } }

  grid.each_with_index do |line, y|
    line.each_with_index do |chr, x|
      next unless chr == ?>
      next_x = (x + 1) % line.length
      if grid[y][next_x] == ?. && new_grid[y][next_x] == ?.
        new_grid[y][next_x] = chr
      else
        raise "Already occupied" unless grid[y][next_x]
        new_grid[y][x] = chr
      end
    end
  end

  grid.each_with_index do |line, y|
    line.each_with_index do |chr, x|
      next unless chr == ?v
      next_y = (y + 1) % grid.length
      if new_grid[next_y][x] == ?. && grid[next_y][x] != ?v
        new_grid[next_y][x] = chr
      else
        raise "Already occupied" unless new_grid[y][x] == ?.
        new_grid[y][x] = chr
      end
    end
  end

  new_grid
end

new_grid = nil
step = 0

loop do
  step += 1
  new_grid = step(grid)
  if new_grid == grid
    p step
    break
  end
  grid = new_grid
end
