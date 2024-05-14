require 'set'
require_relative './core.rb'
require_relative './side.rb'

DIRECTIONS = [
  [0, -1],  # N
  [ 1, 0],  # E
  [0,  1],  # S
  [-1, 0]   # W
]

SYMBOLS = {
  10 => "\n",
  46 => ?.,
  35 => ?#,
  94 => ?^
}

code = File.read('input.txt')
core = Core.new(code, [])

loop do
  break if core.halted
  core.run
end

# current_input, offset = default_map, 1
current_input, offset = core.output.reverse, 0

def print_blocks(blocks)
  blocks.each do |char_code|
    print SYMBOLS.fetch(char_code) { char_code.chr if char_code < 1000  }
  end
  puts
end

def scaffolds(blocks)
  scaffold = Set.new
  grid_for(blocks).each_with_index do |row, y|
    row.each_with_index do |block, x|
      scaffold << [y, x] if block == ?#
    end
  end
  scaffold
end

def grid_for(blocks)
  x, y = 0, 0
  grid = Array.new(100) { [] }
  blocks.each do |char_code|
    grid[y][x] = SYMBOLS.fetch(char_code) unless SYMBOLS.fetch(char_code) == "\n"

    if SYMBOLS.fetch(char_code) == "\n"
      x  = 0
      y += 1
    else
      x += 1
    end
  end
  grid.reject(&:empty?)
end


def cross?(blocks, i, j)
  DIRECTIONS
    .map { |(x, y)| [i + x, j + y] }
    .all? { |pair| blocks.include?(pair) }
end

def start(blocks)
  grid_for(blocks).each_with_index do |row, y|
    row.each_with_index do |block, x|
      return [x, y] if block == "^"
    end
  end
end


print_blocks(current_input)

scaffolds_map = scaffolds(current_input)
answer1 = scaffolds_map
  .select { |(i, j)| cross?(scaffolds_map, i, j) }
  .map { |(i, j)| [i, (j - offset)]  }
  .map { |(i, j)| i * j }
  .sum

def traverse(blocks)
  grid = grid_for(blocks)
  x, y = start(blocks)
  direction = DIRECTIONS[0]
  path = []

  xrange = Range.new(0, grid.first.length - 1)
  yrange = Range.new(0, grid.length - 1)

  loop do
    direction_id = DIRECTIONS.index(direction)

    left = DIRECTIONS[(direction_id - 1) % 4]
    right = DIRECTIONS[(direction_id + 1) % 4]

    left_x, left_y = x + left[0], y + left[1]
    right_x, right_y = x + right[0], y + right[1]

    if xrange.cover?(left_x) && yrange.cover?(left_y) && grid[left_y][left_x] == ?#
      direction = left
      path << ?L
    elsif xrange.cover?(right_x) && yrange.cover?(right_y) && grid[right_y][right_x] == ?#
      direction = right
      path << ?R
    else
      break
    end

    steps = 0
    while grid[y + direction[1]] && grid[y + direction[1]][x + direction[0]] == ?# do
      steps += 1
      x += direction[0]
      y += direction[1]
    end

    path << steps
  end

  path
end

def sequnce_sub(line, core, letter)
  result = []
  skip = 0
  line.each_with_index { |current, idx|
    if skip > 0
      skip -= 1
      next
    end
    substring = line.slice(idx, core.length)
    if substring == core
      result << letter
      skip = core.length - 1
    else
      result << current
    end
  }
  result
end


MAX_LEN = 20
ALL_CORES = %w[A B C]
def compact_path(path, cores = ALL_CORES, desc = [])
  stack = []
  stack << [path, cores, desc]

  while !stack.empty? do
    new_path, new_cores, new_desc = stack.pop
    return [new_path, new_desc] if new_cores.to_a.empty? && new_path.all? { |x| ALL_CORES.include?(x) }
    next if new_cores.empty?

    idx = new_path.find_index { |ch| %w[L R].include?(ch.to_s) }

    (0..MAX_LEN).reverse_each do |max_len|
      next if idx + max_len > new_path.length
      candidate = new_path.slice(idx, max_len)
      next if candidate.length < 2
      next if candidate.join(?,).length > MAX_LEN
      next if candidate.last.is_a?(String)

      new_core = candidate
      new_core_letter = new_cores[0]


      stack << [sequnce_sub(new_path, new_core, new_core_letter), new_cores[1..], new_desc + [new_core]]
    end
  end
end

path = traverse(current_input)
routine, descs = compact_path(path)

routine_line = (routine.join(",") + "\n")
functions_lines = descs.map { |x| x.join(",") + "\n" }

VIDEO_MODE = false

video = (VIDEO_MODE ? 'y' : 'n') + "\n"

code = File.read('input.txt')
core = Core.new(code, [routine_line, *functions_lines, video].join.chars.map(&:ord))
core.awaiting_in = false
core.memory[0] = 2

log = false

loop do
  break if core.halted
  core.run

  next unless VIDEO_MODE

  if core.output.first.chr == "?"
    print_blocks(core.output.reverse)
    core.output.clear
    log = true
  end

  if log && core.output&.length > 1710
    puts "\e[H\e[2J"
    print_blocks(core.output.reverse)
    core.output.clear
    sleep 0.05
  end
end

answer2 = core.output[0]

p [answer1, answer2]
