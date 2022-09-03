require 'set'

data = File.read("input.txt").split("\n").map { |line|
  id, rest =  line.split(" @ ")
  id = id.slice(1..).to_i
  cords, size = rest.split(": ")
  off_left, off_top = cords.split(",").map(&:to_i)
  width, height = size.split("x").map(&:to_i)

  [id, off_left, off_top, width, height]
}

max_right  = data.map { |_, off_left, _, width, _| off_left + width }.max + 1
max_bottom = data.map { |_, _, off_top, _, height| off_top + height }.max + 1

box = Array.new(max_bottom) { |i| Array.new(max_right) { 0 } }

data.each do |_, off_left, off_top, width, height|
  (off_left...(off_left + width)).each do |x|
    (off_top...(off_top + height)).each do |y|
      box[y][x] += 1
    end
  end
end

part1 = box.flatten.count { _1 > 1 }

box = Array.new(max_bottom) { |i| Array.new(max_right) { Set.new } }

data.each do |id, off_left, off_top, width, height|
  (off_left...(off_left + width)).each do |x|
    (off_top...(off_top + height)).each do |y|
      box[y][x] << id
    end
  end
end

candidates = Set.new
overlaps = Set.new
box.flatten(1).reject(&:empty?).each do |chunk|
  if chunk.size == 1
    candidates << chunk.first
  else
    chunk.each { overlaps << _1 }
  end
end

part2 = (candidates - overlaps).first

p [part1, part2]
