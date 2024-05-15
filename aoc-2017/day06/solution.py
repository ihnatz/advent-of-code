import itertools

content = open("input.txt").read()

def maxi(array): return max(range(len(array)), key=lambda i: array[i])

banks = list(map(int, content.strip().split()))
n = len(banks)

known = set()
first_time = -1
second_time = -1

for cycle_id in itertools.count(1):
  banks_tuple = tuple(banks)
  if banks_tuple in known:
    if first_time == -1:
      first_time = cycle_id
      known = set([banks_tuple])
    else:
      second_time = cycle_id
      break

  known.add(banks_tuple)
  max_idx = maxi(banks)
  max_val = banks[max_idx]
  banks[max_idx] = 0
  for i in range(max_val):
    banks[(max_idx + i + 1) % n] += 1

print(first_time)
print(second_time - first_time)
