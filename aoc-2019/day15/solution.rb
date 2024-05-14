require "./core"

SYMBOLS = {
  0 => '#',
  1 => '.',
  2 => 'x',
  3 => "+",
  -1 => 's'
}


require 'io/console'

def read_char
  begin
    # save previous state of stty
    old_state = `stty -g`
    # disable echoing and enable raw (not having to press enter)
    system "stty raw -echo"
    c = STDIN.getc.chr
    # gather next two characters of special keys
    if(c=="\e")
    extra_thread = Thread.new{
      c = c + STDIN.getc.chr
      c = c + STDIN.getc.chr
    }
    # wait just long enough for special keys to get swallowed
    extra_thread.join(0.00001)
    # kill thread so not-so-long special keys don’t wait on getc
    extra_thread.kill
  end
  rescue => ex
    puts "#{ex.class}: #{ex.message}"
    puts ex.backtrace
  ensure
    # restore previous state of stty
    system "stty #{old_state}"
  end
  return c
end



def print_blocks(blocks)
  puts "\e[H\e[2J"

  # xrange = Range.new(*blocks.map(&:first).minmax)
  # yrange = Range.new(*blocks.map(&:first).minmax)

  xrange = (-20..20)
  yrange = (-20..20)

  objects = blocks.map { |t| [t.first(2), t.last] }.to_h

  yrange.each_with_index do |y, i|
    xrange.each do |x|
      print SYMBOLS[objects[[x, y]]] || ' '
    end
    puts
  end
end

def to_code(ch)
  case ch
    when "w" then 2
    when "s" then 1
    when "a" then 3
    when "d" then 4
    else nil
  end
end

def next_coordinates(x, y, dir)
  case dir
  when 1 then [x, y + 1]
  when 2 then [x, y - 1]
  when 3 then [x-1, y]
  when 4 then [x+1, y]
  end
end

require 'set'

# def run(input = [], print = false)
#   code = File.read('input.txt')
#   core = Core.new(code, [])
#   core.awaiting_in = false
#   inputs = []

#   x, y = 0, 0
#   blocks = Set.new
#   blocks << [0, 0, -1]
#   ui = nil

#   loop do
#     break if core.halted
#     core.run

#     if core.awaiting_in
#       out = core.output.first

#       if ui && out
#         if out == 0
#           blocks << [*next_coordinates(x, y, ui), 0]
#           return 0
#         end
#         if out == 1
#           x, y = next_coordinates(x, y, ui)
#           return 0 if blocks.include?([x, y, 1])
#           blocks << [x, y, 1]
#         end
#         if out == 2
#           blocks << [*next_coordinates(x, y, ui), 2]
#           return 2
#         end
#       end

#       print_blocks(blocks + [[x, y, 3]]) && sleep(0.04) if print

#       # dir = read_char
#       # ui = to_code(dir)

#       return 1 if input.empty?
#       ui = input.shift

#       core.input = [ui]
#       core.awaiting_in = false
#     end
#   end
# end


# def backtrack(c)
#   stack = [c]
#   while !stack.empty?
#     current = stack.pop
#     result = run(current.dup)

#     next if result == 0

#     if result == 2
#       p ["HOORAY", current]
#       break
#     else
#       (1..4).each do |s|
#         stack << (current + [s])
#       end
#     end
#   end
# end

def run2(input = [], print = false)
  code = File.read('input.txt')
  core = Core.new(code, [])
  core.awaiting_in = false
  inputs = []

  x, y = 0, 0
  blocks = Set.new
  blocks << [0, 0, -1]
  ui = nil

  loop do
    break if core.halted
    core.run

    if core.awaiting_in
      out = core.output.first

      if ui && out
        if out == 0
          blocks << [*next_coordinates(x, y, ui), 0]
          return [0, blocks]
        end
        if out == 1
          x, y = next_coordinates(x, y, ui)
          return [0, blocks + [[x, y, 1]]] if blocks.include?([x, y, 1])
          blocks << [x, y, 1]
        end
        if out == 2
          blocks << [*next_coordinates(x, y, ui), 2]
          return [2, blocks]
        end
      end

      print_blocks(blocks + [[x, y, 3]]) && sleep(0.04) if print

      # dir = read_char
      # ui = to_code(dir)

      return 1 if input.empty?
      ui = input.shift

      core.input = [ui]
      core.awaiting_in = false
    end
  end
end


def backtrack2(c)
  total_blocks = Set.new
  stack = [c]
  while !stack.empty?
    current = stack.pop
    result, blocks = run2(current.dup)

    total_blocks += blocks.to_a

    next if result == 0
    next if result == 2

    (1..4).each do |s|
      stack << (current + [s])
    end
  end

  total_blocks
end


# backtrack([])
# r = backtrack2([])

blocks = Marshal.load(File.read('blocks.txt'))

# run(
#   [3, 3, 1, 1, 1, 1, 4, 4, 2, 2, 4, 4, 1, 1, 4, 4, 4, 4, 1, 1, 1, 1, 4, 4, 1, 1, 4, 4, 4, 4, 4, 4, 1, 1, 1, 1, 4, 4, 1, 1, 4, 4, 2, 2, 2, 2, 3, 3, 2, 2, 4, 4, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 3, 3, 1, 1, 1, 1, 3, 3, 3, 3, 1, 1, 3, 3, 2, 2, 3, 3, 2, 2, 4, 4, 2, 2, 2, 2, 4, 4, 1, 1, 1, 1, 4, 4, 2, 2, 2, 2, 4, 4, 2, 2, 4, 4, 2, 2, 3, 3, 3, 3, 1, 1, 3, 3, 3, 3, 3, 3, 3, 3, 2, 2, 3, 3, 2, 2, 3, 3, 1, 1, 3, 3, 3, 3, 1, 1, 1, 1, 3, 3, 2, 2, 2, 2, 2, 2, 3, 3, 1, 1, 1, 1, 3, 3, 1, 1, 4, 4, 1, 1, 1, 1, 4, 4, 1, 1, 3, 3, 1, 1, 3, 3, 1, 1, 4, 4, 4, 4, 1, 1, 1, 1, 3, 3, 1, 1, 3, 3, 1, 1, 1, 1, 3, 3, 2, 2, 3, 3, 3, 3, 3, 3, 2, 2, 3, 3, 1, 1, 3, 3, 1, 1, 4, 4, 1, 1, 4, 4, 2, 2, 4, 4, 4, 4, 1, 1, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 2, 2, 2, 2, 4, 4, 4, 4, 2, 2, 4, 4, 2, 2, 3, 3, 3, 3, 1, 1, 3, 3, 2, 2, 2, 2, 4, 4, 4, 4, 2, 2, 4, 4, 1, 1, 4, 4, 1, 1, 1, 1, 1, 1, 3, 3, 1, 1, 1, 1, 4, 4, 2, 2, 4, 4, 4, 4, 2, 2, 2, 2, 3, 3, 2, 2, 4, 4, 4, 4, 1, 1, 1, 1, 4, 4, 1, 1, 3, 3, 1, 1, 4, 4, 4, 4, 2, 2, 4, 4, 1, 1],
# )

start = blocks.find { |x| x.last == 2 }
blocks.delete(start)
finish = blocks.first
blocks.delete(finish)
tick = 0
current_level = [start]
while !current_level.empty?
  new_level = []
  current_level.each do |cell|
    blocks.delete(cell)
  end
  current_level.each do |cell|
    new_level << [cell[0] + 1, cell[1], 1] if blocks.include?([cell[0] + 1, cell[1], 1])
    new_level << [cell[0] - 1, cell[1], 1] if blocks.include?([cell[0] - 1, cell[1], 1])
    new_level << [cell[0], cell[1] + 1, 1] if blocks.include?([cell[0], cell[1] + 1, 1])
    new_level << [cell[0], cell[1] - 1, 1] if blocks.include?([cell[0], cell[1] - 1, 1])
  end
  current_level = new_level
  tick += 1 unless new_level.empty?
end

p tick
