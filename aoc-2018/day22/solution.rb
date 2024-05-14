C = 20183

# depth = 510
# target = [10, 10]

depth = 11820
target = [7, 782]

max_x, max_y = target

MEM = {}
def errosion(x, y, max_x, max_y, depth)
  return MEM[[x, y]] if MEM[[x, y]]

  MEM[[x, y]] = case [x, y]
  in 0, 0 then depth % C
  in _, 0 then (x * 16807 + depth) % C
  in 0, _ then (y * 48271 + depth) % C
  in ^max_x, ^max_y then depth % C
  else (errosion(x - 1, y, max_x, max_y, depth) * errosion(x, y - 1, max_x, max_y, depth) + depth) % C
  end
end

def print_area(map, target)
  max_x, max_y = target

  (0..max_y).each do |y|
    (0..max_x).each do |x|
      if [x, y] == [0, 0]
        print "M"
        next
      end

      if [x, y] == [max_x, max_y]
        print "T"
        next
      end
      print case map[[x, y]]
      when 0 then "."
      when 1 then "="
      when 2 then "|"
      end
    end
    puts
  end
end

def calculate_part1(depth, target)
  max_x, max_y = target
  area = {}
  (0..max_x).each do |x|
    (0..max_y).each do |y|
      area[[x, y]] = errosion(x, y, max_x, max_y, depth)
    end
  end
  map = area.transform_values { _1 % 3 }
  # print_area(map, target)
  map.values.sum
end

part1 = calculate_part1(depth, target)

NEITHER = 0b00
TORCH = 0b01
CLIMBING = 0b10

ALLOW = {
  0 => [CLIMBING, TORCH],
  1 => [CLIMBING, NEITHER],
  2 => [TORCH, NEITHER]
}

def h(x, y, max_x, max_y, ntool)
  (max_x - x).abs + (max_y - y).abs + (ntool == TORCH ? 0 : 7)
end

def d(current, neighbor)
  current[2] == neighbor[2] ? 1 : 8
end

def binary_insert(a, e)
  idx = a.bsearch_index { |x| x.last >= e.last } || a.size
  a.insert(idx, e)
end

start = [0, 0, TORCH]
q = [[*start, 0]]
gscore = {start => 0}

until q.empty?
  top = q.shift
  x, y, equip, _priority = top
  current = [x, y, equip]

  break if [x, y] == [max_x, max_y]

  [
    [x + 1, y],
    ([x - 1, y] if x - 1 >= 0),
    [x, y + 1],
    ([x, y - 1] if y - 1 >= 0)
  ].compact.each do |nx, ny|
    next_type = errosion(nx, ny, max_x, max_y, depth) % 3
    current_type = errosion(x, y, max_x, max_y, depth) % 3

    (ALLOW[next_type] & ALLOW[current_type]).each do |new_tool|
      neighbor = [nx, ny, new_tool]
      tentative_gscore = gscore[current] + d(current, neighbor)

      if gscore[neighbor].nil? || tentative_gscore < gscore[neighbor]
        gscore[neighbor] = tentative_gscore
        heur = tentative_gscore + h(nx, ny, max_x, max_y, new_tool)
        binary_insert(q, [*neighbor, heur])
      end
    end
  end
end

part2 = [
  (gscore[[max_x, max_y, CLIMBING]] || Float::INFINITY) + 7,
  gscore[[max_x, max_y, TORCH]]
].compact.min

p [part1, part2]
