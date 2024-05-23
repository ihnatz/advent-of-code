from functools import reduce
from typing import List
import operator as op

INPUT = 'vbqugkhl'
TAIL = [17, 31, 73, 47, 23]

def cxor(arr): return reduce(op.xor, arr)

def number_of_islands(grid: List[List[str]]) -> int:
    N = len(grid)
    M = len(grid[0])

    def fill(grid, sx, sy):
        dirs = [(0, 1), (1, 0), (-1, 0), (0, -1)]
        q = [(sx, sy)]
        grid[sy][sx] = 0
        while q:
            x, y = q.pop(0)
            for dx, dy in dirs:
                nx, ny = x + dx, y + dy
                if 0 <= ny < N and 0 <= nx < M and grid[ny][nx] == '1':
                    grid[ny][nx] = 0
                    q.append((nx, ny))

    count = 0
    for y in range(N):
        for x in range(M):
            if grid[y][x] == '1':
                count += 1
                fill(grid, x, y)

    return count

def swap(nums, pos, L):
    nums = nums[pos:] + nums[:pos]
    nums[:L] = reversed(nums[:L])
    nums = nums[-pos:] + nums[:-pos]
    return nums

def hash(nums, lenghts_sequence, current_position = 0, skip_size = 0, N = 256):
  for length in lenghts_sequence:
    nums = swap(nums, current_position, length)
    current_position = (current_position + length + skip_size) % N
    skip_size += 1
  return (nums, current_position, skip_size)

def to_lenseq(string):
  return list(map(ord, string)) + TAIL

def to_hex(nums, chunk_size = 16):
  N = len(nums)
  return ''.join(['{:02x}'.format(cxor(nums[i:i + chunk_size])) for i in range(0, N, chunk_size)])

def hash2(lenghts_sequence, rounds = 64, N = 256):
  nums = list(range(N))
  current_position = skip_size = 0

  for _ in range(rounds):
    nums, current_position, skip_size = hash(nums, lenghts_sequence, current_position, skip_size)

  return format(int(to_hex(nums), base=16), '0128b')

matrix = [list(hash2(to_lenseq(f"{INPUT}-{i}"))) for i in range(128)]
print(sum(row.count('1') for row in matrix))
print(number_of_islands(matrix))
