require 'set'

input = File.read("input.txt")
# input = "COM)B
# B)C
# C)D
# D)E
# E)F
# B)G
# G)H
# D)I
# E)J
# J)K
# K)L
# "

# input = "COM)B
# B)C
# C)D
# D)E
# E)F
# B)G
# G)H
# D)I
# E)J
# J)K
# K)L
# K)YOU
# I)SAN"

pairs = input.split("\n").map { |it| it.split(")") }
graph = pairs.inject({}) { |result, (out, to)|
  result[out] ||= []
  result[out] << to
  result
}

def dfs(graph, discovered, v)
  discovered << v
  graph[v].to_a.each do |new_v|
    if !discovered.include?(new_v)
      dfs(graph, discovered, new_v)
    end
  end
end

def bfs(graph, root)
  counters = {}
  pathes = {}
  pathes[root] = []
  counters[root] = 0
  parrents = {}
  q = [root]
  visited = Set.new
  visited << root

  while !q.empty? do
    v = q.shift
    graph[v].to_a.each do |w|
      parrents[w] ||= []
      parrents[w] << v
      counters[w] = counters[v] + 1
      pathes[w] = pathes[v] + [v]
      if !visited.include?(w)
        visited << w
        q.unshift(w)
      end
    end
  end

  [counters, parrents, pathes]
end

def bfs_path(graph, start, finish)
  q = [[start]]
  visited = Set.new

  while !q.empty? do
    path = q.pop
    vertex = path.last

    return path if vertex == finish

    if !visited.include?(vertex)
      graph[vertex].to_a.each do |current_neighbour|
        new_path = path.dup
        new_path << current_neighbour
        q << new_path
      end

      visited << vertex
    end
  end
end


counters, parrent, pathes = bfs(graph, "COM")

last_connected = (pathes["YOU"] & pathes["SAN"]).last
x1 = bfs_path(graph, last_connected, "YOU")
x2 = bfs_path(graph, last_connected, "SAN")

answer1 = counters.values.sum
answer2 = x1.count + x2.count - 2 - 2

p [answer1, answer2]
