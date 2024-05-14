require 'set'

input = """
start-A
start-b
A-c
A-b
b-d
A-end
b-end
""".strip

# input = """
# dc-end
# HN-start
# start-kj
# dc-start
# dc-HN
# LN-dc
# HN-end
# kj-sa
# kj-HN
# kj-dc
# """

input = File.read('input.txt').strip

connections = input.split("\n").map { |line|
  from, to = line.split("-")
  { from => [to], to => [from] }
}.inject { |result, hash| result.merge(hash) { |key, old_value, new_value| old_value + new_value } }

def can_visit_part_2?(node, current_visited, start_node, end_node)
  return false if [start_node, end_node].include?(node)
  return true if node == node.upcase
  connected = current_visited - [start_node, end_node]

  histogram = connected.tally

  if histogram.values.include?(2)
    return (histogram[node] || 0) == 0
  else
    return (histogram[node] || 0) < 2
  end
end

def can_visit_part_1?(node, current_visited, start_node, end_node)
  !current_visited.include?(node)
end

def bfs(connections, start_node, end_node, part)
  queue = [[start_node, [], []]]
  pathes = []

  until queue.empty?
    current_node, current_path, current_visited = queue.shift
    current_path << current_node

    current_visited << current_node unless current_node == current_node.upcase

    connections[current_node].to_a.each do |node|
      if node != end_node
        can_be_visited = part == :part2 ? can_visit_part_2?(node, current_visited, start_node, end_node) : can_visit_part_1?(node, current_visited, start_node, end_node)
        queue << [node, current_path.dup, current_visited.dup] if can_be_visited
      else
        pathes << current_path + [end_node]
      end
    end
  end

  pathes
end

answer1 = bfs(connections, "start", "end", :part1).count
answer2 = bfs(connections, "start", "end", :part2).count

p [answer1, answer2]
