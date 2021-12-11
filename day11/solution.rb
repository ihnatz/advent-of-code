require 'set'

input = """
5483143223
2745854711
5264556173
6141336146
6357385478
4167524645
2176841721
6882881134
4846848554
5283751526
""".strip

# input = """
# 11111
# 19991
# 19191
# 19991
# 11111
# """.strip

input = File.read("input.txt").strip

steps = 100
octogrid = input.split("\n").map { |x| x.chars.map(&:to_i) }

def pp(m)
  m.each do |row|
    puts row.join("")
  end
  puts
end

def neighbors(octogrid, y, x)
  [
    [y - 1, x - 1],
    [y - 1, x],
    [y - 1, x + 1],
    [y, x - 1],
    [y, x + 1],
    [y + 1, x - 1],
    [y + 1, x],
    [y + 1, x + 1],
  ].select { |y, x| y >= 0 && y < octogrid.size && x >= 0 && x < octogrid[0].size }
end

def flash(nextgen, flashed, y, x)
  return if flashed.include?([y, x])
  flashed.add([y, x])

  neighbors(nextgen, x, y).each do |nx, ny|
    nextgen[ny][nx] += 1
  end

  neighbors(nextgen, x, y).each do |nx, ny|
    flash(nextgen, flashed, ny, nx) if nextgen[ny][nx] > 9
  end
end

total = 0
steps.times do
  nextgen = Array.new(octogrid.size) { Array.new(octogrid[0].size) }

  # step 1
  octogrid.each_with_index do |row, y|
    row.each_with_index do |num, x|
      nextgen[y][x] = num + 1
    end
  end

  # step 2
  flashed = Set.new
  nextgen.each_with_index do |row, y|
    row.each_with_index do |num, x|
      flash(nextgen, flashed, y, x) if num > 9
    end
  end

  flashed.each do |y, x|
    nextgen[y][x] = 0
  end

  total += flashed.size
  octogrid = nextgen
end

answer1 = total


step = 1
octogrid = input.split("\n").map { |x| x.chars.map(&:to_i) }
loop do
  nextgen = Array.new(octogrid.size) { Array.new(octogrid[0].size) }

  # step 1
  octogrid.each_with_index do |row, y|
    row.each_with_index do |num, x|
      nextgen[y][x] = num + 1
    end
  end

  # step 2
  flashed = Set.new
  nextgen.each_with_index do |row, y|
    row.each_with_index do |num, x|
      flash(nextgen, flashed, y, x) if num > 9
    end
  end

  flashed.each do |y, x|
    nextgen[y][x] = 0
  end

  total += flashed.size
  octogrid = nextgen
  step += 1

  break if nextgen.flatten.all?(&:zero?)
end

answer2 = step

p [answer1, answer2]
