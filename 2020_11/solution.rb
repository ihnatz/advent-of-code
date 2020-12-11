FLOOR    = -1
EMPTY    = 0
OCCUPIED = 1

SEATS_AROUND = [
  [0, -1],
  [1, -1],
  [1, 0],
  [1, 1],
  [0, 1],
  [-1, 1],
  [-1, 0],
  [-1, -1]
]

INPUT = File.read('input.txt').split("\n").map(&:chars)
FIELD = INPUT.map { |row|
  row.map { |column|
    case column
    when '.' then FLOOR
    when 'L' then EMPTY
    when '#' then OCCUPIED
    end
  }
}

ROWS = FIELD.length
COLUMNS = FIELD[0].length

def valid_offset?(i, j, offset_x, offset_y)
  (0...ROWS).include?(i + offset_x) && (0...COLUMNS).include?(j + offset_y)
end

def cells_around(i, j)
  SEATS_AROUND
    .select { |(x, y)| valid_offset?(i, j, x, y) }
    .map { |(x, y)| [i + x, j + y] }
end

def next_generation(field)
  result = Array.new(ROWS) { Array.new(COLUMNS) }

  ROWS.times do |i|
    COLUMNS.times do |j|
      occupied_count = cells_around(i, j).count { |(x, y)| field[x][y] == OCCUPIED }
      result[i][j] = case
      when field[i][j] == FLOOR then FLOOR
      when occupied_count == 0 && field[i][j] == EMPTY then OCCUPIED
      when occupied_count >= 4 && field[i][j] == OCCUPIED then EMPTY
      else field[i][j]
      end
    end
  end

  result
end

def print_field(matrix)
  matrix.each do |row|
    row.each do |column|
      x = case column
      when  FLOOR then '.'
      when  EMPTY  then 'L'
      when  OCCUPIED then '#'
      end
      print(x)
    end
    puts
  end
end

current_field = FIELD
next_field = next_generation(current_field)

puzzle1 = loop {
  break(current_field) if current_field == next_field
  current_field = next_field
  next_field = next_generation(current_field)
}.sum { |row|
  row.count { _1 == OCCUPIED }
}

def seats_rays(i, j)
  ray_length = [ROWS, COLUMNS].max
  SEATS_AROUND
    .map { |(x, y)|
      (1...ray_length)
        .select { |step| valid_offset?(i, j, x * step, y * step) }
        .map { |step| [x * step, y * step] }
    }.reject(&:empty?).map { |ray|
      ray.map { |(x, y)| [i + x, j + y] }
    }
end

def calculate_on_ray(field, ray)
  i, j = ray.find { |(i,j)| field[i][j] != FLOOR }
  field[i][j] if i && j
end

def next_complex_generation(field)
  result = Array.new(ROWS) { Array.new(COLUMNS) }

  ROWS.times do |i|
    COLUMNS.times do |j|
      seats_around = seats_rays(i, j).count { |ray| calculate_on_ray(field, ray) == OCCUPIED }

      result[i][j] = case
      when field[i][j] == FLOOR then FLOOR
      when seats_around == 0 && field[i][j] == EMPTY then OCCUPIED
      when seats_around >= 5 && field[i][j] == OCCUPIED then EMPTY
      else field[i][j]
      end

    end
  end

  result
end

current_field = FIELD
next_field = next_complex_generation(current_field)

puzzle2 = loop {
  break(current_field) if current_field == next_field
  current_field = next_field
  next_field = next_complex_generation(current_field)
}.sum { |row|
  row.count { _1 == OCCUPIED }
}

p [puzzle1, puzzle2]
