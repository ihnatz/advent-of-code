L = [70,66,255,2,48,0,54,48,80,141,244,254,160,108,1,41]
TAIL = [17, 31, 73, 47, 23]

def cxor(arr):
  t = 0
  for v in arr:
    t ^= v
  return t

assert 64 == cxor([65, 27, 9, 1, 4, 3, 40, 50, 91, 7, 6, 0, 2, 5, 68, 22])

def swap(arr, l, r):
  sub = [arr[i % len(arr)] for i in range(l, r)]
  for i, val in enumerate(reversed(sub)):
    arr[(l + i) % len(arr)] = val

arr = [2,1,0,3,4]; swap(arr, 3, 7)
assert arr == [4, 3, 0, 1, 2]

def hash(clist, lenghts_sequence, cp = 0, ss = 0):
  clist = clist[::]
  current_position = cp
  skip_size = ss

  for length in lenghts_sequence:
    swap(clist, current_position, current_position + length)
    current_position = (current_position + length + skip_size) % len(clist)
    skip_size += 1

  return (clist, current_position, skip_size)

def hash2(clist, lenghts_sequence):
  cp = ss = 0
  for _ in range(64):
    clist, cp, ss = hash(clist, lenghts_sequence, cp, ss)
  return clist

lenghts_sequence = L
clist = list(range(256))
result = hash(clist, L)[0]
print(result[0] * result[1])

lenghts_sequence = list(map(ord, (",".join(map(str, L))))) + TAIL
clist = list(range(256))
sparse = hash2(clist, lenghts_sequence)
n = 16
print(''.join([hex(cxor(sparse [i:i + n]))[2:] for i in range(0, len(sparse ), n)]))
