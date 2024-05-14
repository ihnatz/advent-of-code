require './core'

code = File.read('input.txt')
core = Core.new(code, [])

require 'set'

DIRECTIONS = [:up, :right, :down, :left]

whites = Set.new
visited = Set.new

x, y = 0, 0
direction = :up

loop do
  visited << [x, y]

  break if core.halted

  current_command = whites.include?([x, y]) ? 1 : 0
  core.input = [current_command]

  paintcmd = core.run&.first
  break if core.halted
  dircmd = core.run&.first

  if paintcmd == 0
    whites.delete([x, y])
  else
    whites.add([x, y])
  end

  direction = if dircmd == 0
    DIRECTIONS[(DIRECTIONS.index(direction) - 1) % DIRECTIONS.length]
  else
    DIRECTIONS[(DIRECTIONS.index(direction) + 1) % DIRECTIONS.length]
  end

  case direction
    when :up then y += 1
    when :down then y -= 1
    when :left then x -= 1
    when :right then x += 1
  end
end

answer1 = visited.count
p answer1


code = File.read('input.txt')
core = Core.new(code, [])

whites = Set.new
visited = Set.new

x, y = 0, 0
direction = :up
whites << [x, y]

loop do
  break if core.halted

  current_command = whites.include?([x, y]) ? 1 : 0
  core.input = [current_command]

  paintcmd = core.run&.first
  break if core.halted
  dircmd = core.run&.first

  if paintcmd == 0
    whites.delete([x, y])
  else
    whites.add([x, y])
  end

  direction = if dircmd == 0
    DIRECTIONS[(DIRECTIONS.index(direction) - 1) % DIRECTIONS.length]
  else
    DIRECTIONS[(DIRECTIONS.index(direction) + 1) % DIRECTIONS.length]
  end

  case direction
    when :up then y += 1
    when :down then y -= 1
    when :left then x -= 1
    when :right then x += 1
  end
end

xrange = Range.new(*whites.map(&:first).minmax)
yrange = Range.new(*whites.map(&:last).minmax)


xrange.each do |x|
  yrange.each do |y|
    print (whites.include?([x, y]) ? '■' : ' ')
  end
  puts
end
