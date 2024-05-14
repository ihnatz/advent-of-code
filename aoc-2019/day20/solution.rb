require 'set'

input = File.read("input.txt").split("\n")
max   = input.map(&:length).max
grid  = input.map! { |line| line.ljust(max).chars }

def neighbours(coordinates, borders)
  [
    [0, 1],
    [0, -1],
    [1, 0],
    [-1, 0]
  ].map { |(off_x, off_y)| [coordinates[0] + off_x, coordinates[1] + off_y] }
   .reject { |neighbour| neighbour.zip(borders).any? { |dimension, range| !range.cover?(dimension) } }
end

def parse_portals(grid)
  portals = []
  grid.each_with_index do |row, y|
    row.each_with_index do |block, x|
      next if grid[y + 1].nil?
      if ('A'..'Z').cover?(grid[y][x]) && ('A'..'Z').cover?(grid[y + 1][x])
        portal_name = grid[y][x] + grid[y + 1][x]
        y_cord = grid[y + 2] && grid[y + 2][x] == "." ? y + 2 : y - 1
        delta = y > 2 && y < grid.length - 2 ? -1 : 1

        portals << [portal_name, delta, x, y_cord]
      end

      if ('A'..'Z').cover?(grid[y][x]) && ('A'..'Z').cover?(grid[y][x + 1])
        portal_name = grid[y][x] + grid[y][x + 1]
        x_cord = grid[y][x - 1] == "." ? x - 1 : x + 2
        delta = x > 2 && x < row.length - 2 ? -1 : 1

        portals << [portal_name, delta, x_cord, y]
      end
    end
  end
  portals
end

portals = parse_portals(grid)

start  = portals.find { |(name, _, _)| name == "AA" }.last(2)
finish = portals.find { |(name, _, _)| name == "ZZ" }.last(2)

portals_map = portals
    .reject { |(name, _, _)| ["AA", "ZZ"].include?(name) }
    .group_by(&:first).values
    .inject({}) { |mapping, (incoming, outcoming)|
      mapping[incoming.last(2)] = outcoming.last(3)
      mapping[outcoming.last(2)] = incoming.last(3)
      mapping
    }

max_x, max_y = grid[0].length - 1, grid.length - 1

all_paths = {}
([start] + portals_map.keys).each do |from|
  q = [from]
  distances = { from => 0 }
  paths = {}

  while !q.empty? do
    x, y = q.shift

    neighbours([x, y], [0..max_x, 0..max_y]).each do |next_x, next_y|
      current = grid[next_y][next_x]

      next unless current == ?.
      next if distances[[next_x, next_y]]
      distances[[next_x, next_y]] = distances[[x, y]] + 1

      if finish == [next_x, next_y]
        paths[finish] = [distances[[next_x, next_y]], 0]
      elsif portals_map[[next_x, next_y]]
        delta, x_to, y_to = portals_map[[next_x, next_y]]
        paths[[x_to, y_to]] = [distances[[next_x, next_y]] + 1, delta]
      else
        q << [next_x, next_y]
      end
    end
  end

  all_paths[from] = paths
end

def dijkstra(map, start)
  visited = Set.new
  q = [start]
  distances = { start => 0 }

  while !q.empty? do
    from_point = q.shift
    next if visited.include?(from_point)
    visited << from_point

    map[from_point].to_a.each do |to_point, (distance, _delta)|
      if (distances[from_point] + distance) < (distances[to_point] || Float::INFINITY)
        distances[to_point] = distance + distances[from_point]
      end
      q << to_point
    end
  end

  distances
end

def dijkstra_with_levels(map, start, finish)
  visited = Set.new
  q = [[start, 0]]
  distances = { [start, 0] => 0 }

  while !q.empty? do
    from = q.shift
    from_point, from_level = from
    next if visited.include?(from)
    visited << from

    if map[from_point].to_h.keys.include?(finish) && from_level == 0
      return distances[from] + map[from_point][finish].first
    end

    map[from_point].to_a.each do |to_point, (distance, delta)|
      to = [to_point, from_level + delta]

      next if from_level + delta < 0

      if (distances[from] + distance) < (distances[to] || Float::INFINITY)
        distances[to] = distance + distances[from]
      end

      q << to
    end
  end
end

answer1 = dijkstra(all_paths, start)[finish]
answer2 = dijkstra_with_levels(all_paths, start, finish)

p [answer1, answer2]
