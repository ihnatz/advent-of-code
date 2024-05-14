DIRECIONS = {
  "E" => [1, 0],
  "S" => [0, -1],
  "W" => [-1, 0],
  "N" => [0, 1]
}

INSTRUCTIONS =
  File
    .read("input.txt")
    .split("\n")
    .map { [_1[0], _1.slice(1..).to_i] }

def move_coordinates(x, y, offset, multiplier)
  [x + offset[0] * multiplier, y + offset[1] * multiplier]
end

def rotate_vector(x, y, degree)
  beta = degree * Math::PI / 180

  x1 = x * Math.cos(beta) - y * Math.sin(beta)
  y1 = y * Math.cos(beta) + x * Math.sin(beta)

  [x1, y1].map(&:round)
end

puzzle1 =
  INSTRUCTIONS
    .inject([0, 0, 0]) { |(x, y, direction), (command, argument)|
    case command
    when *DIRECIONS.keys
      x, y = move_coordinates(x, y, DIRECIONS[command], argument)
    when "F"
      x, y = move_coordinates(x, y, DIRECIONS.values[direction], argument)
    when "R"
      direction = (direction + (argument / 90)) % 4
    when "L"
      direction = (direction - (argument / 90)) % 4
    end
    [x, y, direction]
  }.first(2).sum(&:abs)

puzzle2 =
  INSTRUCTIONS
    .inject([0, 0, 10, 1]) { |(x, y, wx, wy), (command, argument)|
    case command
    when "F"
      x, y = move_coordinates(x, y, [wx, wy], argument)
    when *DIRECIONS.keys
      wx, wy = move_coordinates(wx, wy, DIRECIONS[command], argument)
    when "R"
      wx, wy = rotate_vector(wx, wy, -argument)
    when "L"
      wx, wy = rotate_vector(wx, wy, argument)
    end

    [x, y, wx, wy]
  }.first(2).sum(&:abs)

p [puzzle1, puzzle2]
