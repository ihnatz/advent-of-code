def clean_garbage(string):
  result = ''
  garbaged = ''
  skip = garbage = False
  for char in string:
    if skip:
      skip = False
    elif garbage and char == ">":
      garbage = False
    elif not garbage and char == "<":
      garbage = True
    elif not garbage:
      result += char
    elif char == "!":
      skip = True
    elif garbage:
      garbaged += char
    else:
      raise Exception("Unknown state")

  return result, garbaged

assert clean_garbage("<>")[0] == ""
assert clean_garbage("<random characters>")[0] == ""
assert clean_garbage("<<<<<>")[0] == ""
assert clean_garbage("<{!>}>")[0] == ""
assert clean_garbage("<!!>")[0] == ""
assert clean_garbage("<!!!>>")[0] == ""
assert clean_garbage('<{o"i!a,<{i<a>')[0] == ""
assert clean_garbage('{}')[0] == "{}"
assert clean_garbage("{{<!>},{<!>},{<!>},{<a>}}")[0] == "{{}}"
assert clean_garbage("{{}}")[0] == "{{}}"

def count_groups(string):
  t = lvl = 0
  for val in string:
    if val == "{":
      lvl += 1
      t += lvl
    elif val == "}":
      lvl -= 1
  return t

assert count_groups(clean_garbage("{{{},{},{{}}}}")[0]) == 16
assert count_groups(clean_garbage("{{<ab>},{<ab>},{<ab>},{<ab>}}")[0]) == 9
assert count_groups(clean_garbage("{{<!!>},{<!!>},{<!!>},{<!!>}}")[0]) == 9
assert count_groups(clean_garbage("{{<a!>},{<a!>},{<a!>},{<ab>}}")[0]) == 3

string = open("input.txt").read().strip()
print(count_groups(clean_garbage(string)[0]))
print(len(clean_garbage(string)[1]))
