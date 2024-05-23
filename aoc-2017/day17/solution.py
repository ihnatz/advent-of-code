J = 328

class Node():
  __slots__ = ('value', 'nextNode')

  def __init__(self, value, nextNode = None):
    self.value = value
    self.nextNode = nextNode or self

  def skip(self, count):
    current = self
    for _ in range(count):
      current = current.nextNode
    return current

  def insert(self, value):
    new_node = Node(i, self.nextNode)
    self.nextNode = new_node
    return new_node

buffer = Node(0)
for i in range(1, 2017 + 1):
  buffer = buffer.skip(J).insert(i)
print(buffer.nextNode.value)

current_idx = 0
buffer = [0, 0]
for i in range(1, 50000000):
  current_idx = (current_idx + J) % i + 1
  if current_idx <= 1:
    buffer[current_idx] = i
print(buffer[1])
