require './core'

CODE = File.read('input.txt')

def check(x, y)
  core = Core.new(CODE, [x, y])
  core.run == [1]
end

def answer1
  count = 0
  (0..49).each do |x|
    (0..49).each do |y|
      count += 1 if check(x, y)
    end
  end
  count
end



def answer2
  x = 0
  y = 100

  loop {
    y += 1
    while !check(x, y) do x += 1 end
    break if check(x + 99, y - 99)
  }

  x * 10_000 + (y - 99)
end

p [answer1, answer2]
