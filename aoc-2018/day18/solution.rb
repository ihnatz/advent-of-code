require 'set'

# input = File.read("sample.txt")
input = File.read("input.txt")

def print_area(area, trees, lumberyards, opens)
  area.each_with_index do |row, j|
    line = row.each_with_index.map do |val, i|
      if opens.include?([i, j])
        ?.
      elsif lumberyards.include?([i, j])
        ?#
      else
        ?|
      end
    end
    puts line.join
  end
  puts
end

def neighbors(area, i, j)
  [
    [-1, -1],
    [-1, 0],
    [-1, 1],
    [0, -1],
    [0, 1],
    [1, -1],
    [1, 0],
    [1, 1]
  ].filter_map { |(dx, dy)|
    [i + dx, j + dy] if j + dy >= 0 && j + dy < area.length && i + dx >= 0 && i + dx < area.length
  }
end

def run_round(area, trees, opens, lumberyards)
  new_trees = Set.new
  new_lumberyards = Set.new
  new_opens = Set.new

  opens.each do |(i, j)|
    if neighbors(area, i, j).count { trees.include?(_1) } >= 3
      new_trees << [i, j]
    else
      new_opens << [i, j]
    end
  end

  trees.each do |(i, j)|
    if neighbors(area, i, j).count { lumberyards.include?(_1) } >= 3
      new_lumberyards << [i, j]
    else
      new_trees << [i, j]
    end
  end

  lumberyards.each do |(i, j)|
    lumberyard_count = neighbors(area, i, j).count { lumberyards.include?(_1) }
    trees_count = neighbors(area, i, j).count { trees.include?(_1) }

    if lumberyard_count >= 1 && trees_count >= 1
      new_lumberyards << [i, j]
    else
      new_opens << [i, j]
    end
  end

  [new_trees, new_opens, new_lumberyards]
end

trees = Set.new
lumberyards = Set.new
opens = Set.new

area = input.split("\n").map(&:strip).map(&:chars)
area.each_with_index do |row, j|
  row.each_with_index do |val, i|
    case val
    when ?. then opens
    when ?# then lumberyards
    when ?| then trees
    else raise
    end << [i, j]
  end
end


part1_limit = 10
part2_limit = 1_000_000_000

part1 = nil
part2 = nil

minute = 0
states = Set.new
stable_points = []

loop do
  break if minute == part2_limit

  minute += 1
  state = [trees.sort, opens.sort, lumberyards.sort].join
  if states.include?(state)
    stable_points << minute
    states = Set.new

    if stable_points.length > 1
      period = (stable_points[1] - stable_points[0])
      periods = (part2_limit - minute) / period
      minute += periods * period
    end

  end
  states << state

  trees, opens, lumberyards = run_round(area, trees, opens, lumberyards)
  part1 = lumberyards.count * trees.count if minute == part1_limit
  part2 = lumberyards.count * trees.count if minute == part2_limit
end

p [part1, part2]
