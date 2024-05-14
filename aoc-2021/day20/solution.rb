require 'set'

input = if true
  File.read("input.txt")
else
  File.read("sample.txt")
end.strip

algo, image = input.split("\n\n")
algo = algo.split("\n").join
image = image.strip.split("\n").map(&:chars)

SHIFTS = [
    [  - 1, - 1],
    [    0, - 1],
    [    1, - 1],
    [  - 1,   0],
    [    0,   0],
    [    1,   0],
    [  - 1,   1],
    [    0,   1],
    [    1,   1]
  ]

def square(pixel)
  x, y = pixel
  SHIFTS.map { |(dx, dy)| [x + dx, y + dy] }
end

def frame(light_pixels, pixel, blink = false)
  square(pixel).map { |neighbor|
    light_pixels.include?(neighbor) == !blink ? "1" : "0"
  }.join.to_i(2)
end

light_pixels = Set.new
image.each_with_index do |line, y|
  line.each_with_index do |char, x|
    light_pixels << [x, y] if char == ?#
  end
end


def step(algo, light_pixels, blink = false)
  new_generation = Set.new
  visited = Set.new

  light_pixels.each do |(x, y)|
    SHIFTS.each do |dx, dy|
      new_pixel = [x + dx, y + dy]
      next if visited.include?(new_pixel)
      visited << new_pixel

      v = frame(light_pixels, new_pixel, blink)
      new_generation << new_pixel if (algo[v] == ?#) == blink
    end
  end

  new_generation
end

result = step(algo, step(algo, light_pixels), true)
answer1 = result.size

24.times {  |i|
  p i
  result = step(algo, step(algo, result), true)
}
answer2 = result.size

p [answer1, answer2]

