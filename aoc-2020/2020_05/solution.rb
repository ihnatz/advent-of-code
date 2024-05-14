class Seat
  def initialize(line)
    @line = line
  end

  def row
    @line[0..6].gsub("F", "0").gsub("B", "1").to_i(2)
  end

  def column
    @line[7..9].gsub("R", "1").gsub("L", "0").to_i(2)
  end

  def seat_id
    row * 8 + column
  end
end

seats = File.read("input.txt").split("\n").map { |line| Seat.new(line) }
expected_sum = (100 + puzzle1) * (puzzle1 - 99) / 2

puzzle1 = seats.map(&:seat_id).max
puzzle2 = expected_sum - seats.map(&:seat_id).sum

p [puzzle1, puzzle2]
