from collections import defaultdict
import operator as op

file= open("input.txt").readlines()

operations = {'>': op.gt, '>=': op.ge, '==': op.eq, '<': op.lt, '<=': op.le, '!=': op.ne}
highest = 0

registers = defaultdict(int)
for line in file:
  r1, operation, amout, _if, r2, condition, condition_amount = line.split()

  if operations[condition](registers[r2], int(condition_amount)):
    amout = int(amout) if operation == 'inc' else -int(amout)
    registers[r1] += amout
    highest = max(highest, registers[r1])

print(max(registers.values()))
print(highest)
