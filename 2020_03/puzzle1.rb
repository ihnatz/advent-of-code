field = File.read('input.txt').split("\n").map(&:chars)
height = field.count
width = field[0].count

STEP = 3

result = height.times.map do |iteration|
  y = (iteration * STEP % width)
  x = iteration
  field[x][y]
end.count("#")

p result
