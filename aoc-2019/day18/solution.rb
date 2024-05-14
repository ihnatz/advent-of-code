require 'set'

input = File.read('input.txt')
grid  = input.split("\n").map(&:chars)

def neighbours(coordinates, borders)
  [
    [0, 1],
    [0, -1],
    [1, 0],
    [-1, 0]
  ].map { |(off_x, off_y)| [coordinates[0] + off_x, coordinates[1] + off_y] }
   .reject { |neighbour| neighbour.zip(borders).any? { |dimension, range| !range.cover?(dimension) } }
end


def starts(grid)
  starts = []
  grid.each_with_index do |row, y|
    row.each_with_index do |block, x|
      starts << [x, y] if block == "@"
    end
  end
  starts
end

def keys_positions(grid)
  keys = {}
  grid.each_with_index do |row, y|
    row.each_with_index do |block, x|
      keys[block] = [x, y] if (?a..?z).cover?(block)
    end
  end
  keys
end

State = Struct.new(:x, :y, :keys, :path)

def answer_1(grid)
  max_x, max_y = grid.first.length - 1, grid.length - 1
  root = State.new(*starts(grid).first, '', 0)

  q = [root]
  visited  = Hash.new
  alphabet = grid.flatten.select { |block| ('a'..'z').cover?(block) }.sort.join

  while !q.empty? do
    state = q.shift

    next if visited[state.keys] && visited[state.keys].include?([state.x, state.y])
    visited[state.keys] ||= Set.new
    visited[state.keys] << [state.x, state.y]

    if state.keys == alphabet
      return state.path
      break
    end

    neighbours([state.x, state.y], [0..max_x, 0..max_y]).each do |next_x, next_y|
      current = grid[next_y][next_x]

      next if current == ?#

      case current
      when ?., ?@ then q << State.new(next_x, next_y, state.keys, state.path + 1)
      when ('a'..'z') then q << State.new(next_x, next_y, (state.keys.chars + [current]).uniq.sort.join, state.path + 1)
      when ('A'..'Z') then (q << State.new(next_x, next_y, state.keys, state.path + 1) if state.keys.include?(current.downcase))
      end
    end
  end
end


p answer_1(grid)

grid[39][40] = ?#
grid[40][40] = ?#
grid[41][40] = ?#

grid[40][39] = ?#
grid[40][41] = ?#

grid[41][41] = ?@
grid[39][39] = ?@
grid[39][41] = ?@
grid[41][39] = ?@

BOTS = (1..4).map(&:to_s).to_a
MEM = {}

def reachable_neighbors(distances, positions, unlocked)
  keys = []

  positions.each_with_index do |from_key, starter|
    distances[from_key].each do |key, needed_keys, distance|
      next if unlocked.include?(key)
      next if (needed_keys - unlocked).any?
      keys << [starter, key, distance]
    end
  end

  keys
end

def min_path(positions, distances, unlocked = [])
  cache_key = [positions.sort.join, unlocked.sort.join].join(":")
  return MEM[cache_key] if MEM[cache_key]

  MEM[cache_key] = reachable_neighbors(distances, positions, unlocked).map do |starter, key, distance|
    current = positions[starter]
    positions[starter] = key
    (distance + min_path(positions, distances, unlocked + [key])).tap {
      positions[starter] = current
    }
  end.min || 0
end

def answer_2(grid)
  max_x, max_y = grid.first.length - 1, grid.length - 1
  start = starts(grid)
  keys_positions = keys_positions(grid)
  distances = {}

  keys_positions.merge(BOTS.zip(start).to_h).each do |key, position|
    q = [[*position, []]]
    distance = { position => 0 }
    keys = []

    while !q.empty? do
      x, y, needed_keys = q.shift
      neighbours([x, y], [0..max_x, 0..max_y]).each do |next_x, next_y|
        current = grid[next_y][next_x]

        next if current == ?#
        next if distance[[next_x, next_y]]

        distance[[next_x, next_y]] = distance[[x, y]] + 1

        keys << [current, needed_keys, distance[[next_x, next_y]]] if ('a'..'z').cover?(current)
        q << [next_x, next_y, ('A'..'z').cover?(current) ? needed_keys + [current.downcase] : needed_keys]
      end
    end
    distances[key] = keys
  end

  min_path(BOTS, distances)
end

p answer_2(grid)
