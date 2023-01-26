# require 'bundler/inline'

# gemfile(true) do
#   source 'https://rubygems.org'
#   gem 'chunky_png'
#   gem 'pry'
#   gem 'debug'
# end
# require 'chunky_png'
# ZOOM = 1

START = [500, 0]
# input = File.read("sample.txt"); MAX_X = 600; MAX_Y = 100
input = File.read("input.txt"); MAX_X = 1000; MAX_Y = 2000


# def show(clay, stale, drops)
#   png = ChunkyPNG::Image.new(MAX_X * ZOOM + 1, MAX_Y * ZOOM + 1, ChunkyPNG::Color::TRANSPARENT)
#   (0...MAX_Y).each do |y|
#     (0...MAX_X).each do |x|
#       color = case
#       when clay.include?([x, y]) then ChunkyPNG::Color.rgba(0, 0, 0, 255)
#       when stale.include?([x, y]) then ChunkyPNG::Color.rgba(0, 0, 255, 255)
#       when drops.include?([x, y]) then ChunkyPNG::Color.rgba(100, 100, 255, 255)
#       else ChunkyPNG::Color.rgba(255, 255, 255, 255)
#       end

#       (x * ZOOM..(x + 1) * ZOOM).each do |zx|
#         (y * ZOOM..(y + 1) * ZOOM).each do |zy|
#           png[zx, zy] = color
#         end
#       end
#     end
#   end

#   png.save('/mnt/d/filename.png')
# end


parsed = input.split("\n").map(&:strip).map { |line|
  xs, ys = line.split(", ").sort
  xs.delete!("x=")
  ys.delete!("y=")

  xs = xs.include?("..") ? Range.new(*xs.split("..").map(&:to_i)) : [xs.to_i]
  ys = ys.include?("..") ? Range.new(*ys.split("..").map(&:to_i)) : [ys.to_i]

  [xs, ys]
}

min_x = parsed.map(&:first).flat_map(&:min).min
max_x = parsed.map(&:first).flat_map(&:max).max
min_y = parsed.map(&:last).flat_map(&:min).min
max_y = parsed.map(&:last).flat_map(&:max).max

require 'set'
cyan = Set.new

parsed.each do |xs, ys|
  ys.each do |y|
    xs.each do |x|
      cyan << [x, y]
    end
  end
end


$filled = {}
def fill_level(point, stale, drops, cyan)
  streams = []
  to_add =[]

  x, y = point

  return $filled[[point, y]] if $filled.include?([point, y])

  loop do
    if !cyan.include?([x - 1, y]) && !stale.include?([x - 1, y])
      x -= 1
      drops << [x, y]

      if !cyan.include?([x, y + 1]) && !stale.include?([x, y + 1])
        streams << [x, y + 1]
        break
      end

      to_add << [x, y]
    else
      break
    end
  end

  x, y = point

  loop do
    if !cyan.include?([x + 1, y]) && !stale.include?([x + 1, y])
      x += 1
      drops << [x, y]

      if !cyan.include?([x, y + 1]) && !stale.include?([x, y + 1])
        streams << [x, y + 1]
        break
      end

      to_add << [x, y]
    else
      break
    end
  end

  if streams.count == 0
    to_add.each { stale << _1 }
    stale << point
    $filled[[point, y]] = streams
  end

  streams
end


def fill(cyan)
  stale = Set.new
  drops = Set.new
  streams = Set.new

  streams << START

  t = 0
  max_y = cyan.map(&:last).max + 1

  while !streams.empty?
    t += 1

    stream = streams.first
    streams.delete(stream)

    next if stale.include?(stream)

    x, y = stream
    next if y >= max_y
    drops << [x, y] if y < max_y

    loop do
      if !cyan.include?([x, y + 1]) && !stale.include?([x, y + 1]) && y < max_y
        y += 1
        drops << [x, y]
      else
        break
      end
    end

    next_streams = fill_level([x, y], stale, drops, cyan)
    next_streams.each { streams << _1 }
    streams << START if streams.empty?
  end

  [stale, drops]
end

# def show(cyan, stale, drops, hl = [], start = 0, count = 50, sx = 200)
# (start..start + count).each do |y|
# (sx..sx + 200).each do |x|
#   if hl.include?([x, y])
#     print '*'
#     next
#   end
#   if [x, y] == START
#     print '+'
#     next
#   end
#   if stale.include?([x, y])
#     print '~'
#     next
#   end
#   if drops.include?([x, y])
#     print '|'
#     next
#   end
#   print cyan.include?([x, y]) ? '#' : '.'
# end
# puts
# end

# end


stale, drops = fill(cyan)
max_y = cyan.map(&:last).max
drops.reject! { |x, y| y > max_y || y < min_y }

# show(cyan, stale, drops)

part1 = drops.count
part2 = stale.count

p [part1, part2]
