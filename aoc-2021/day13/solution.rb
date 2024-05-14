input = """
6,10
0,14
9,10
0,3
10,4
4,11
6,0
6,12
4,1
0,13
10,12
3,4
3,0
8,4
1,10
2,14
8,10
9,0

fold along y=7
fold along x=5
""".strip

input = File.read('input.txt').strip

def pp(matrix)
  matrix.each do |row|
    puts row.join('')
  end
  puts
end

instset, foldset = input.split("\n\n")
instructions = instset.split("\n").map { |line| line.split(",").map(&:to_i) }
folds = foldset.split("\n")

max_x = instructions.map(&:first).max
max_y = instructions.map(&:last).max

field = Array.new(max_y + 1) { Array.new(max_x + 1) { 0 } }

instructions.each do |x, y|
  field[y][x] = 1
end

def fold_y(pos, field)
  top = field.slice(0, pos.to_i)
  bottom = field.slice(pos.to_i + 1, field.size)

  reversed_bottom = bottom.transpose.map(&:reverse).transpose

  top.each_with_index do |row, i|
    row.each_with_index do |cell, j|
      top[i][j] = cell | reversed_bottom[i][j]
    end
  end

  top
end

def fold_x(pos, field)
  left = field.transpose.slice(0, pos.to_i).transpose.map(&:reverse)
  right = field.transpose.slice(pos.to_i + 1, field[0].size).transpose


  right.each_with_index do |row, i|
    row.each_with_index do |cell, j|
      right[i][j] = cell | left[i][j]
    end
  end

  right
end

folds.slice(0, 1).each do |fold|
  _, _, desc = fold.split(" ")
  cord, pos = desc.split("=")

  if cord == "y"
    field = fold_y(pos, field)
  else
    field = fold_x(pos, field)
  end
end

answer1 = field.flatten.sum

field = Array.new(max_y + 1) { Array.new(max_x + 1) { 0 } }

instructions.each do |x, y|
  field[y][x] = 1
end

folds.each do |fold|
  _, _, desc = fold.split(" ")
  cord, pos = desc.split("=")

  if cord == "y"
    field = fold_y(pos, field)
  else
    field = fold_x(pos, field)
  end
end

p answer1
field.each do |row|
  puts row.reverse.map { |x| x == 1 ? "#" : " " }.join('')
end
puts
