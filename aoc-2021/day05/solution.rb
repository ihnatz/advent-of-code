input = """
0,9 -> 5,9
8,0 -> 0,8
9,4 -> 3,4
2,2 -> 2,1
7,0 -> 7,4
6,4 -> 2,0
0,9 -> 2,9
3,4 -> 1,4
0,0 -> 8,8
5,5 -> 8,2
""".strip
grid = Array.new(10) { Array.new(10, 0) }

def pretty_print_board(board)
  board.transpose.each do |row|
    puts row.map {|z| z.to_s.rjust(3)}.join(" ")
  end
  puts
end

input = File.read("input.txt")
grid1 = Array.new(1000) { Array.new(1000, 0) }

input.split("\n").each do |line|
  c1, c2 = line.split(" -> ")
  x1, y1 = c1.split(",").map(&:to_i)
  x2, y2 = c2.split(",").map(&:to_i)

  y1, y2 = y2, y1 if y2 < y1
  x1, x2 = x2, x1 if x2 < x1

  if (x1 == x2)
    (y1..y2).each do |y|
      grid1[y][x1] += 1
    end
  elsif (y1 == y2)
    (x1..x2).each do |x|
      grid1[y1][x] += 1
    end
  end
end

answer1 = grid1.flatten.select {|z| z > 1}.count

grid2 = Array.new(1000) { Array.new(1000, 0) }

input.split("\n").each do |line|
  c1, c2 = line.split(" -> ")
  x1, y1 = c1.split(",").map(&:to_i)
  x2, y2 = c2.split(",").map(&:to_i)

  if (x1 == x2)
    y1, y2 = y2, y1 if y2 < y1
    (y1..y2).each do |y|
      grid2[x1][y] += 1
    end
  elsif (y1 == y2)
    x1, x2 = x2, x1 if x2 < x1
    (x1..x2).each do |x|
      grid2[x][y1] += 1
    end
  elsif (x1 - x2).abs == (y1 - y2).abs
    x1, y1, x2, y2 = x2, y2, x1, y1  if x1 > x2

    if y2 >= y1
      while x1 <= x2
        grid2[x1][y1] += 1
        x1 += 1
        y1 += 1
      end
    else
      while x1 <= x2
        grid2[x1][y1] += 1
        x1 += 1
        y1 -= 1
      end
    end
  end
end

answer2 = grid2.flatten.select {|z| z > 1}.count

p [answer1, answer2]
