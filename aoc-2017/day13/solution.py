import itertools

file = open("input.txt")

network = {}
for line in file.readlines():
  layer, lrange = line.split(": ")
  network[int(layer)] = int(lrange)

def pass_through(count, network, delay):
  for second in network.keys():
    if (second + delay) % (2 * (network[second] - 1)) == 0:
      yield((second, network[second]))

def caught_records(count, network, delay = 0):
  return list(pass_through(count, network, delay))

def has_been_caught(count, network, delay):
  return any(pass_through(count, network, delay))

count = max(network.keys())
print(sum(k * v for k, v in caught_records(count, network)))
print(next(delay for delay in itertools.count() if not has_been_caught(count, network, delay)))
