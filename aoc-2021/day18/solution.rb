inp1 = [[[[[9,8],1],2],3],4]
inp2 = [7,[6,[5,[4,[3,2]]]]]
inp3 = [[6,[5,[4,[3,2]]]],1]
inp4 = [[3,[2,[1,[7,3]]]],[6,[5,[4,[3,2]]]]]
inp5 = [[3,[2,[8,0]]],[9,[5,[4,[3,2]]]]]

class Node
  attr_accessor :left, :right, :parrent

  def initialize(left, right, parrent)
    @left = left
    @right = right
    @parrent = parrent
  end

  def inspect
    "[#{left&.inspect || '*'}, #{right&.inspect || '*'}]"
  end

  def to_s
    "Node #{inspect}"
  end
end

def to_tree(list, root = nil)
  left, right = list
  new_root = Node.new(nil, nil, root)

  if left
    new_root.left = left.is_a?(Array) ? to_tree(left, new_root) : left
  end

  if right
    new_root.right = right.is_a?(Array) ? to_tree(right, new_root) : right
  end

  new_root
end

def add(a, b)
  root = Node.new(a, b, nil)
  a.parrent = root
  b.parrent = root
  root
end

def nested?(root)
  stack = [[root, 0]]
  levels = []

  loop do
    break if stack.empty?
    node, lvl = stack.pop
    levels << lvl
    stack << [node.left, lvl + 1] if node.left.is_a?(Node)
    stack << [node.right, lvl + 1] if node.right.is_a?(Node)
  end

  levels.any? { |lvl| lvl > 3 }
end

def leftmost_nested(root)
  stack = [[root, "", 0]]
  suspicious = []

  loop do
    break if stack.empty?
    node, left, lvl = stack.pop
    suspicious << [node, left] if lvl > 3

    stack << [node.left, left + "L", lvl + 1] if node.left.is_a?(Node)
    stack << [node.right, left + "R", lvl + 1] if node.right.is_a?(Node)
  end

  suspicious.map! { |(node, val)|
    [
      node,
      val.chars.map { |x| x == "L" ? 1 : 0 }
    ]
  }

  raise "Can't decide" if suspicious.map(&:last).count > 1 && suspicious.map(&:last).uniq.count == 1

  suspicious.max_by(&:last).first
end

def closest_left(start)
  common = start.parrent
  return [nil, nil] if common.nil?
  return closest_left(common) if common.left == start
  if common.left
    return [common, :left] if common.left.is_a?(Numeric)
    new_common = common.left
    while new_common.right.is_a?(Node) do new_common = new_common.right end
    return [new_common, :right]
  end
end

def closest_right(start)
  common = start.parrent
  return [nil, nil] if common.nil?
  return closest_right(common) if common.right == start
  if common.right
    return [common, :right] if common.right.is_a?(Numeric)
    new_common = common.right
    while new_common.left.is_a?(Node) do new_common = new_common.left end
    return [new_common, :left]
  end
end

def explode(root)
  node_to_explode = leftmost_nested(root)

  to_explode =  node_to_explode.parrent.right == node_to_explode ? :right : :left

  left_value, right_value = node_to_explode.left, node_to_explode.right

  lnode, ldirection = closest_left(node_to_explode)
  lnode.send("#{ldirection}=", lnode.send("#{ldirection}") + left_value) if lnode

  rnode, rdirection = closest_right(node_to_explode)
  rnode.send("#{rdirection}=", rnode.send("#{rdirection}") + right_value) if rnode

  node_to_explode.parrent.send("#{to_explode}=", 0)

  root
end

def high?(root)
  stack = [root]
  values = []

  loop do
    break if stack.empty?
    node = stack.pop
    values << node.left if node.left.is_a?(Numeric)
    values << node.right if node.right.is_a?(Numeric)

    stack << node.left if node.left.is_a?(Node)
    stack << node.right if node.right.is_a?(Node)
  end

  values.any? { |val| val > 9 }
end

def leftmost_high(root)
  stack = [[root, '']]
  suspicious = []

  loop do
    break if stack.empty?
    node, left = stack.pop
    suspicious << [node, left + "L"] if node.left.is_a?(Numeric) && node.left > 9
    suspicious << [node, left + "R"] if node.right.is_a?(Numeric) && node.right > 9

    stack << [node.left,  left + "L"] if node.left.is_a?(Node)
    stack << [node.right, left + "R"] if node.right.is_a?(Node)
  end

  suspicious.map! { |(node, val)|
    [
      node,
      val.chars.map { |x| x == "L" ? 1 : 0 },
    ]
  }

  raise "Can't decide" if suspicious.map(&:last).count > 1 && suspicious.map(&:last).uniq.count == 1

  suspicious.max_by(&:last).first
end

def split(root)
  node_to_split = leftmost_high(root)

  if node_to_split.left.is_a?(Numeric) && node_to_split.left > 9
    node_to_split.left = Node.new(
      (node_to_split.left / 2.0).floor,
      (node_to_split.left / 2.0).ceil,
      node_to_split
    )
  else
    node_to_split.right = Node.new(
      (node_to_split.right / 2.0).floor,
      (node_to_split.right / 2.0).ceil,
      node_to_split
    )
  end
end

def clean(tree)
  loop do
    if nested?(tree)
      explode(tree)
      next
    end

    if high?(tree)
      split(tree)
      next
    end

    break if !nested?(tree) && !high?(tree)
  end
end

def magnitude(tree)
  if tree.left.is_a?(Numeric) && tree.right.is_a?(Numeric)
    return tree.left * 3 + tree.right * 2
  end

  left = if tree.left.is_a?(Node)
    magnitude(tree.left)
  else
    tree.left
  end

  right = if tree.right.is_a?(Node)
    magnitude(tree.right)
  else
    tree.right
  end

  3 * left + 2 * right
end


inputs = File.read("input.txt").strip.split("\n").map  { |x| eval(x) }

tree = to_tree(inputs.shift)
loop do
  break if inputs.empty?
  one = to_tree(inputs.shift)
  tree = add(tree, one)
  clean(tree)
end

answer1 = magnitude(tree)

def calc(a, b)
  one = to_tree(a)
  tree = add(one, to_tree(b))
  clean(tree)
  magnitude(tree)
end

inputs = File.read("input.txt").strip.split("\n").map  { |x| eval(x) }
answer2 = inputs.product(inputs).map { |(a, b)| calc(a, b) }.max

p [answer1, answer2]
