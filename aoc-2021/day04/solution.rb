require 'json'

input = """
7,4,9,5,11,17,23,2,0,14,21,24,10,16,13,6,15,25,12,22,18,20,8,19,3,26,1

22 13 17 11  0
 8  2 23  4 24
21  9 14 16  7
 6 10  3 18  5
 1 12 20 15 19

 3 15  0  2 22
 9 18 13 17  5
19  8  7 25 23
20 11 10 24  4
14 21 16 12  6

14 21 17 24  4
10 16 15  9 19
18  8 23 26 20
22 11 13  6  5
 2  0 12  3  7
""".strip

input = File.read("input.txt")

def pretty_print_board(board)
  board.each do |row|
    puts row.map {|z| z.to_s.rjust(3)}.join(" ")
  end
  puts
end

def check_board(board)
  return true if board.any? { |line| line.all? { |z| z == "X" }}
  return true if board.transpose.any? { |line| line.all? { |z| z == "X" }}
  false
end

bingo, *boards = input.split("\n\n")
boards.map! { |x| x.split("\n")}
boards.map! { |x| x.map { |y| y.split(" ").map(&:to_i) } }
bingo = bingo.split(",").map(&:to_i)

boards_dup = JSON.parse(JSON.dump(boards))

answer1 = nil
to_break = false

bingo.each do |num|
  break if to_break
  boards.each do |board|
    board.each_with_index do |row, j|
      row.each_with_index do |col, i|
        if col == num
           board[j][i] = "X"
        end
      end
    end

    result = check_board(board)
    if result
      answer1 = board.flatten.reject { |x| x == "X" }.sum * num
      to_break = true
      break
    end
  end
end

answer2 = nil

boards = boards_dup

bingo.each do |num|
  boards.each_with_index do |board, board_index|
    next if board.nil?
    board.each_with_index do |row, j|
      row.each_with_index do |col, i|
        if col == num
           board[j][i] = "X"
        end
      end
    end

    if check_board(board)
        answer2 = board.flatten.reject { |x| x == "X" }.sum * num
      if  board.length > 1
        boards[board_index] = nil
      end
    end
  end
end

p [answer1, answer2]
