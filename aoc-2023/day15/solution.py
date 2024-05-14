import re
from functools import reduce

steps = open("input.txt").read().strip().split(",")

def hash(string):
    return reduce(lambda current, c: (current + ord(c)) * 17 % 256, string, 0)

boxes = [{} for _ in range(256)]
for (label, operation, arg) in [re.split('(=|-)', step) for step in steps]:
    if arg != "": focal_length = int(arg[0])
    current_box = boxes[hash(label)]

    if operation == "-":
        current_box.pop(label, None)
    if operation == "=":
        current_box[label] = focal_length

print(sum(hash(step) for step in steps))
print(sum((box_idx + 1) * (1 + lense_idx) * focal_length
            for box_idx, box in enumerate(boxes)
            for lense_idx, (_label, focal_length) in enumerate(box.items())))
