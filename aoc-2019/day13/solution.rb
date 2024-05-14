require "./core"

SYMBOLS = {
  0 => ' ',
  1 => '_',
  2 => '■',
  3 => 'v',
  4 => 'o'
}

code = File.read('input.txt')
core = Core.new(code, [])
core.memory[0] = 2
core.awaiting_in = false

def print_blocks(blocks)
  puts "\e[H\e[2J"

  xrange = Range.new(*blocks.map(&:first).minmax)
  yrange = Range.new(*blocks.map(&:first).minmax)
  objects = blocks.map { |t| [t.first(2), t.last] }.to_h

  yrange.each_with_index do |y, i|
    xrange.each do |x|
      if [x, y] == [-1, 0]
        puts "Score: #{objects[[x, y]]}"
      end
      print SYMBOLS[objects[[x, y]]] if SYMBOLS[objects[[x, y]]]
    end
    puts if i < 25
  end
end

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

# opt_way = File.read("cheat.txt").split(",").map(&:to_i)
opt_way = []
core.input = opt_way
inputs = []

def to_code(ch)
  case ch
    when "a" then -1
    when "s", "w" then 0
    when "d" then 1
    else nil
  end
end

loop do
  loop do
    core.run
    if core.awaiting_in || core.halted
      blocks = core.output.reverse.each_slice(3)
      print_blocks(blocks)
    end

    break if core.awaiting_in
    if core.halted
      puts "SCORE: #{core.output[0]}"
      exit
    end
  end

  dir = read_char
  inputs << dir

  ui = case dir
  when "a" then -1
  when "s", "w" then 0
  when "d" then 1
  when "q" then p inputs.map { |x| to_code(x) }.compact; p inputs.size; exit
  end

  core.input = [ui]
  core.awaiting_in = false
end
