def count_trees(field, step_y, step_x)
  height, width = field.count, field[0].count

  (height / step_x).times.map do |iteration|
    y = (iteration * step_y % width)
    x = iteration * step_x
    field[x][y]
  end.count("#")
end

field = File.read('input.txt').split("\n").map(&:chars)
puzzle1 = count_trees(field, 3, 1)
puzzle2 =
  [[1, 1], [3, 1], [5, 1], [7, 1], [1, 2]]
    .map { |steps| count_trees(field, *steps) }
    .reduce(:*)

p [puzzle1, puzzle2]
