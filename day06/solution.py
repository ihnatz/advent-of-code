with open("input.txt") as f:
    content = f.read()

times, dists = content.split("\n")
times = times.replace("Time: ", "")
dists = dists.replace("Distance: ", "")

times = [int(i) for i in times.split()]
dists = [int(i) for i in dists.split()]

def calculate_possible_speeds(time, dist):
    return sum(1 for i in range(1, time + 1) if i * (time - i) > dist)

t = 1
for (time, dist) in zip(times, dists):
    t *= calculate_possible_speeds(time, dist)
part1 = t


times, dists = content.split("\n")
time = int(times.replace("Time: ", "").replace(" ", ""))
dist = int(dists.replace("Distance: ", "").replace(" ", ""))
part2 = calculate_possible_speeds(time, dist)

print(part1)
print(part2)