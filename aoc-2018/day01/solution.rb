require 'set'

data = File.read("input.txt").split("\n").map(&:to_i)

part1 = data.sum

existing = Set.new
current = 0

data.cycle.each do |change|
  current += change
  break if existing.include?(current)
  existing << current
end

part2 = current

p [part1, part2]
