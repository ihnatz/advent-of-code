require 'set'

input = if true
  File.read("input.txt")
else
  File.read("sample2.txt")
end.strip

rules = input
  .split("\n")
  .map { _1.split(" ") }
  .map { [_1, _2.split(",")]}
  .map { [_1, _2.map { |line| line.split("=").last }]}
  .map { [_1, _2.map { |coord| Range.new(*coord.split("..").map(&:to_i)) }]}

def part1(rules)
  mem = {}

  (-50..50).each do |x|
    (-50..50).each do |y|
      (-50..50).each do |z|
        rules.each do |(state, (xr, yr, zr))|
          next unless xr.include?(x) && yr.include?(y) && zr.include?(z)
          mem[[x, y, z]] = state
        end
      end
    end
  end

  mem.values.select { _1 == "on" }.count
end

answer1 = part1(rules)

def trunc(range1, range2)
  return Range.new(0, 0, true) if range1.last < range2.first || range1.first > range2.last
  Range.new([range1.first, range2.first].max, [range1.last, range2.last].min)
end

def intersect(cube1, cube2)
  xr1, yr1, zr1 = cube1
  xr, yr, zr = cube2

  xr2 = trunc(xr, xr1)
  yr2 = trunc(yr, yr1)
  zr2 = trunc(zr, zr1)

  return if [xr2, yr2, zr2].any? { _1.size == 0 }

  [xr2, yr2, zr2]
end

def size(cube)
  xr, yr, zr = cube
  xr.size * yr.size * zr.size
end

def count(step, rest)
  _state, cube = step
  total = size(cube)

  conflicts = rest.map { |(state, substep)|
    conflict = intersect(substep, cube)
    [state, conflict] if conflict
  }.compact

  conflicts.each_with_index do |step, idx|
    total -= count(step, conflicts[idx + 1..])
  end

  total
end

answer2 = rules.each_with_index.inject(0) { |total, (rule, idx)|
  next(total) if rule[0] == "off"
  total + count(rule, rules[idx + 1..])
}

p [answer1, answer2]
