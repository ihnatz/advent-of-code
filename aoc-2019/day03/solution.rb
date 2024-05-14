wire1, wire2 = File.read('input.txt').split("\n")

# wire1 = "R8,U5,L5,D3"; wire2 = "U7,R6,D4,L4"
# wire1 = "R75,D30,R83,U83,L12,D49,R71,U7,L72"; wire2 = "U62,R66,U55,R34,D71,R55,D58,R83"
# wire1 = "R98,U47,R26,D63,R33,U87,L62,D20,R33,U53,R51"; wire2 = "U98,R91,D20,R16,D67,R40,U7,R15,U6,R7"

def to_points(line)
  distances = {}
  x, y = 0, 0
  step = 0
  result = line.split(",").inject([]) { |total, current|
    direction, *number = *current.chars
    number = number.join.to_i

    number.times do
      step += 1
      case direction
      when "R" then x += 1
      when "L" then x -= 1
      when "U" then y += 1
      when "D" then y -= 1
      else
        raise "Unknonw direction"
      end
      total << [x, y]
      distances[[x, y]] ||= step
    end

    total
  }
  distances
end

def to_distance(p1)
  p1[0].abs + p1[1].abs
end

mapping1 = to_points(wire1)
mapping2 = to_points(wire2)
intersections = mapping1.keys & mapping2.keys

answer1 = intersections.map { |it| to_distance(it) }.min
answer2 = intersections.map { |it| mapping1[it] + mapping2[it] }.min

p [answer1, answer2]
