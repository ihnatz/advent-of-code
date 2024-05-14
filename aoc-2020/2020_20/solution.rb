require 'set'
require 'matrix'

$precalculated = {}
input = File.read("example.txt").split("\n\n")

COUNT = input.count
SIDE = Math.sqrt(input.count).to_i

TILES = input.map {
  title, *image = _1.split("\n")
  [title.sub("Tile ", '').sub(':', '').to_i, Matrix[*image.map(&:chars)]]
}.to_h

def print_resulting_matrix(matrix)
  total_image = matrix.to_a.map { |row|
    Matrix[*row.reduce { |result, matrix| result.hstack(matrix) }]
  }.reduce { |result, matrix|
    result.vstack(matrix)
  }

  total_image.to_a.map.with_index { |x, i|
    puts if i % 10 == 0
    puts x.each_slice(10) { |part| print part.join + " " }
  }

  puts
end

def print_matrix(matrix)
  puts matrix.to_a.map(&:join)
  puts
end

def rotate(matrix)
  Matrix[*matrix.transpose.to_a.map(&:reverse)]
end

def flip(matrix, direction: 'h')
  Matrix[*(if direction == 'h'
    matrix.to_a.map(&:reverse)
  else
    matrix.to_a.reverse
  end)]
end

def all_mutations(matrix)
  return $precalculated[matrix] if $precalculated[matrix]

  result = []
  result << matrix
  result << rotate(result.last)
  result << rotate(result.last)
  result << rotate(result.last)
  result << flip(matrix, direction: 'h')
  result << rotate(result.last)
  result << rotate(result.last)
  result << rotate(result.last)

  $precalculated[matrix] = result

  result
end


def right_alignment?(matrix1, matrix2)
  matrix1.column_vectors.last == matrix2.column_vectors.first
end

def left_alignment?(matrix1, matrix2)
  matrix1.column_vectors.first == matrix2.column_vectors.last
end

def top_alignment?(matrix1, matrix2)
  matrix1.to_a.last == matrix2.to_a.first
end

def bottom_alignment?(matrix1, matrix2)
  matrix1.to_a.first == matrix2.to_a.last
end

graph = TILES.inject({}) { |result, (title, matrix)|
  can_align = TILES.map { |ctitle, possible_neighbor|
    next if ctitle == title

    any_align =
      all_mutations(matrix)
        .product(all_mutations(possible_neighbor))
        .any? { |m1, m2|
          top_alignment?(m1, m2)    ||
          bottom_alignment?(m1, m2) ||
          left_alignment?(m1, m2)   ||
          right_alignment?(m1, m2)
        }
    [ctitle, any_align]
  }.compact.select { |(title, reached)| reached }

  result.merge(title => can_align.map(&:first))
}

puzzle1 = graph.sort_by { _2.count }.first(4).map(&:first).inject(&:*)

TILE_IDS = Array.new(SIDE) { Array.new(SIDE, nil) }

def build_image(matrix, x = 0, y = 0, seen = Set.new)
  return matrix if y == SIDE

  next_x = x + 1
  next_y = y

  if next_x == SIDE
    next_x = 0
    next_y += 1
  end

  TILES.each do |id, variant|
    next if seen.include?(id)
    seen << id

    all_mutations(variant).each do |mutation|
      if x > 0
        bottom_neighbor = matrix[x - 1][y]
        next if !bottom_alignment?(mutation, bottom_neighbor)
      end
      if y > 0
        left_neighbor = matrix[x][y - 1]
        next if !left_alignment?(mutation, left_neighbor)
      end

      matrix[x][y] = mutation
      TILE_IDS[x][y] = id

      answer = build_image(matrix, next_x, next_y, seen)
      return answer if answer
    end

    seen.delete(id)
  end

  matrix[x][y] = nil
  TILE_IDS[x][y] = nil
end

total = Array.new(SIDE) { Array.new(SIDE) }
raw_image = build_image(total)

print_resulting_matrix(raw_image)

puts TILE_IDS.map { _1.join(" ") }
puts


# drop borders
(0...SIDE).each do |x|
  (0...SIDE).each do |y|
    processing = raw_image[x][y].to_a
    result = processing.slice(1, processing.size-2).map(&:to_a).map { |x|
      x.slice(1, x.size-2)
    }
    raw_image[x][y] = Matrix[*result]
  end
end

# combine images
total_image = raw_image.to_a.map { |row|
  Matrix[*row.reduce { |result, matrix| result.hstack(matrix) }]
}.reduce { |result, matrix|
  result.vstack(matrix)
}

print_matrix total_image


MONSTER = """
__________________#_
#____##____##____###
_#__#__#__#__#__#___
""".gsub("_", " ").split("\n").drop(1).map(&:chars)


def monster_fits_line?(monstr_line, sea_line, offset = 0)
  mostr_length = monstr_line.length

  result = sea_line.each_cons(mostr_length).with_index.find { |spot, index|
    next if offset > index
    monstr_line.zip(spot).all? { |(monst_part, sea_part)|
      next true if monst_part != '#'
      monst_part == sea_part
    }
  }
  result && result.last
end


def monsters_count(sea)
  sea.each_cons(3).count { |threeline|
    offset = monster_fits_line?(MONSTER[0], threeline[0])
    next unless offset
    monster_fits_line?(MONSTER[1], threeline[1], offset) &&
      monster_fits_line?(MONSTER[2], threeline[2], offset)
  }
end


monster_x = MONSTER.flatten.count("#")
puzzle2 = all_mutations(Matrix[*total_image]).map { |subz|
  sea_x = subz.to_a.flatten(2).count("#")
  sea_x - (monsters_count(subz.to_a) * monster_x)
}.min

p [puzzle1, puzzle2]
