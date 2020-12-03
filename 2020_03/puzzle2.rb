field = File.read('input.txt').split("\n").map(&:chars)
height = field.count
width = field[0].count

result = [[1, 1], [3, 1], [5, 1], [7, 1], [1, 2]].map do |(step_y, step_x)|
  (height / step_x).times.map do |iteration|
    y = (iteration * step_y % width)
    x = iteration * step_x
    field[x][y]
  end.count("#")
end.reduce(:*)

p result
