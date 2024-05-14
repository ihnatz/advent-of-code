input =
".#..##.###...#######
##.############..##.
.#.######.########.#
.###.#######.####.#.
#####.##.#.##.###.##
..#####..#.#########
####################
#.####....###.#.#.##
##.#################
#####.##.###..####..
..######..##.#######
####.##.####...##..#
.#####..#.######.###
##...#.##########...
#.##########.#######
.####.#.###.###.#.##
....##.##.###..#####
.#.#.###########.###
#.#.#.#####.####.###
###.##.####.##.#..##".split("\n").map(&:chars)

input = File.read('input.txt').split("\n").map(&:chars)
greed = input

def find_asteroids(greed)
  coordinates = []
  greed.each_index do |i|
    greed[i].each_index do |j|
      coordinates << [i, j] if greed[i][j] == "#"
    end
  end
  coordinates
end

coordinates = find_asteroids(greed)

places_mapping = coordinates.map { |f|
   angles = coordinates.map { |(x, y)|
    cap_x = x - f[0]
    cap_y = y - f[1]
    next if cap_x == 0 && cap_y == 0

    angle = Math.atan2(cap_x, cap_y)

    [x, y, angle]
  }.compact

  [f, angles.group_by(&:last).keys.count]
}

top_place = places_mapping.max_by(&:last)
answer_1 = top_place.last


top_place_coordinates = top_place.first

all_coordinates = coordinates
all_coordinates.delete(top_place_coordinates)
queue = []

loop do
  angles = all_coordinates.map { |(x, y)|
    cap_x = x - top_place_coordinates[0]
    cap_y = y - top_place_coordinates[1]
    next if cap_x == 0 && cap_y == 0

    angle = Math.atan2(cap_x, cap_y)
    hypot = Math.hypot(cap_x, cap_y)

    [x, y, hypot, angle]
  }.compact.group_by(&:last)

  to_be_vaporized =
    angles
      .map { |x| z = (x.first / Math::PI * 180) + 90 % 360; z = z < 0 ? z + 360 : z; [z, *x] }
      .sort_by(&:first)
      .map(&:last)
      .map { |x| x.sort_by { |z| z[2] }.first }
      .map { |x| [x[0], x[1]] }

  to_be_vaporized.each do |killed|
    all_coordinates.delete(killed)
    queue << killed
  end

  break if all_coordinates.empty?
end

target = queue[199]
answer_2 = target[1] * 100 + target[0]

p [answer_1, answer_2]
