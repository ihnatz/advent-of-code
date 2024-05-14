# input = File.read("sample3.txt")
input = File.read("input.txt")

coordinates = input.split("\n").map { |line| line.split(",").map(&:to_i) }.sort

def dist(a, b)
  (a[0] - b[0]).abs +
    (a[1] - b[1]).abs +
    (a[2] - b[2]).abs +
    (a[3] - b[3]).abs
end

def find(root, el)
  return el if root[el] == el
  root[el] = find(root, root[el])
end

def union(root, rank, x, y)
  root_x = find(root, x)
  root_y = find(root, y)

  if root_x != root_y
    if rank[root_x] > rank[root_y]
      root[root_y] = root_x
    elsif rank[root_x] < rank[root_y]
      root[root_x] = root_y
    else
      root[root_y] = root_x
      rank[root_x] += 1
    end
  end
end

parents = (0..coordinates.count - 1).to_a
ranks = Array.new(coordinates.count, 0)

coordinates.each_with_index do |candidate_point, candidate_parent|
  coordinates.each_with_index do |neighborh_point, neighborh_parent|
    next if find(parents, candidate_parent) == find(parents, neighborh_parent)
    next if dist(candidate_point, neighborh_point) > 3

    union(parents, ranks, candidate_parent, neighborh_parent)
  end
end

part1 = parents.uniq.count
p part1
