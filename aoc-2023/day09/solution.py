content = open("input.txt").read().splitlines()

def predict_next(nums, total=0):
  if all(not val for val in nums): return 0
  return nums[-1] + predict_next([a - b for b, a in zip(nums, nums[1:])])

print(sum([predict_next(list(map(int, line.split()))) for line in content]))
print(sum([predict_next(list(reversed(list(map(int, line.split()))))) for line in content]))