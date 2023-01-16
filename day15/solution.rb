AREA = File.read("input.txt").lines.map(&:chomp).map(&:chars)
# AREA = [
# '#######',
# '#.G...#',
# '#...EG#',
# '#.#.#G#',
# '#..G#E#',
# '#.....#',
# '#######',
# ].map(&:chars)
# 47 * 590 = 27730

# AREA = [
# '#######',
# '#G..#E#',
# '#E#E.E#',
# '#G.##.#',
# '#...#E#',
# '#...E.#',
# '#######'
# ].map(&:chars)
# Outcome: 37 * 982 = 36334

# AREA = [
# '#######',
# '#E..EG#',
# '#.#G.E#',
# '#E.##E#',
# '#G..#.#',
# '#..E#.#',
# '#######',
# ].map(&:chars)
# Outcome: 46 * 859 = 39514

# AREA = [
# '#######',
# '#E.G#.#',
# '#.#G..#',
# '#G.#.G#',
# '#G..#.#',
# '#...E.#',
# '#######',
# ].map(&:chars)
# Outcome: 35 * 793 = 27755

# AREA = [
# '#######',
# '#.E...#',
# '#.#..G#',
# '#.###.#',
# '#E#G#G#',
# '#...#G#',
# '#######',
# ].map(&:chars)
# Outcome: 54 * 536 = 28944

# AREA = [
# '#########',
# '#G......#',
# '#.E.#...#',
# '#..##..G#',
# '#...##..#',
# '#...#...#',
# '#.G...G.#',
# '#.....G.#',
# '#########',
# ].map(&:chars)
# Outcome: 20 * 937 = 18740





def print_area
  AREA.each { puts _1.join }
  nil
end

def print_area_with_units(units)
  AREA.each_with_index { |chars, y|
    line = chars.join
    on_line = units.select { _1.y == y }.map { "#{_1.type}(#{_1.hit_points})" }.join(", ")
    puts [y.to_s.rjust(2, '0'), line, on_line].join("    ")
  }
  nil
end

def neighbors(x, y)
  [
    [0, -1],
    [-1, 0],
    [1, 0],
    [0, 1]
  ].filter_map { |(dx, dy)|
    if (x + dx >= 0 && x + dx < AREA.first.length) && (y + dy >= 0 && y + dy < AREA.length)
      [x + dx, y + dy]
    end
  }
end


class Unit < Struct.new(:x, :y, :type)
  attr_accessor :hit_points

  def initialize(*)
    super
    @hit_points = 200
  end

  def dead?
    hit_points <= 0
  end

  def coordinates
    [y, x]
  end

  def receive_damage(amount)
    @hit_points -= amount
  end

  def enemy
    type == "E" ? "G" : "E"
  end

  def can_move?(units)
    enemies_nearby(units).empty? && !stack?
  end

  def adjacents
    neighbors(x, y).select { |nx, ny| AREA[ny][nx] == ?. }
  end

  def stack?
    adjacents.empty?
  end

  def enemies_nearby(units)
    targets(units).select { neighbors(_1.x, _1.y).include?([x, y]) }
  end

  def target_adjacents(units)
    targets(units).flat_map { |unit| unit.adjacents }
  end

  def targets(units)
    units.select { _1.type != self.type }
  end

  def inspect
    "#{type} #{hit_points} [y: #{y}, x: #{x}]"
  end
end

def get_units
  result = []
  (0...AREA.length).each do |y|
    (0...AREA[0].length).each do |x|
      next unless ('A'..'Z').include?(AREA[y][x])
      result << Unit.new(x, y, AREA[y][x])
    end
  end
  result.sort_by(&:coordinates)
end

require 'debug'
require 'set'

def nearest_target(unit, units)
  obstacles = AREA.map { |row| row.map { _1 != ?. } }

  y, x = unit.coordinates
  q = [[x, y, []]]


  targets = unit.target_adjacents(units).to_set
  found = Set.new
  visited = Set.new

  while !q.empty? do
    x, y, way = q.shift
    next if visited.include?([x, y])
    visited << [x, y]

    neighbors(x, y).each do |nx, ny|
      nway = way + [[nx, ny]]
      if targets.include?([nx, ny])
        found << [nway.length, nway]
      else
        q << [nx, ny, nway] unless obstacles[ny][nx]
      end
    end
  end

  return nil if found.empty?
  min = found.map(&:first).min

  min_finish =
    found
      .select { |path, _| path == min }
      .map { |_, x| finish = x.last; [finish[1], finish[0]] }
      .min
      .reverse

  found
    .select { |path, _| path == min }
    .select { |_, x| x.last == min_finish }
    .min_by { |_, x| start = x.first; [start[1], start[0]] }[1][0]

end

def endgame?(units)
  units.reject(&:dead?).map(&:type).uniq.count == 1
end


def run(elf_attack = 3)
  units = get_units
  stop = false
  rounds = 0

  loop do
    units.reject!(&:dead?)
    units.sort_by!(&:coordinates)

    break if stop

    if DEBUG
      puts "After #{rounds} rounds"
      print_area_with_units(units)
      p units.map(&:hit_points).sum
      # gets
    end

    units.each do |unit|
      next if unit.dead?

      if unit.can_move?(units.reject(&:dead?))
        py, px = unit.coordinates
        nx, ny = nearest_target(unit, units.reject(&:dead?))
        if nx && ny
          AREA[py][px] = '.'
          AREA[ny][nx] = unit.type
          unit.y = ny
          unit.x = nx
        end
      end

      targets = unit.enemies_nearby(units.reject(&:dead?))


      if unit.targets(units.reject(&:dead?)).empty?
        stop = true
        break
      end

      if !targets.empty?
        next_target = targets.min_by(&:hit_points)
        next_target.receive_damage(unit.type == "E" ? elf_attack : 3)
        AREA[next_target.y][next_target.x] = '.' if next_target.dead?
      end
    end

    rounds += 1 unless stop
  end

  [units, rounds]
end

def dup(x)
  Marshal.load(Marshal.dump(x))
end

ORIGINAL_AREA = dup(AREA)
DEBUG = false

AREA = dup(ORIGINAL_AREA)
units, rounds = run
part1 = (units.map { _1.hit_points }.sum) * rounds

AREA = dup(ORIGINAL_AREA)
original_elfs = get_units.count { _1.type == "E" }

expected = (4..50).bsearch { |power|
  AREA = dup(ORIGINAL_AREA)
  units, rounds = run(power)
  (original_elfs == units.count { _1.type == "E" })
}

AREA = dup(ORIGINAL_AREA)
units, rounds = run(expected)
part2 = (units.map { _1.hit_points }.sum) * rounds

p [part1, part2]
