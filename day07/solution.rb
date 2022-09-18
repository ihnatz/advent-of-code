descriptions =
  File
    .read("input.txt")
    .split("\n")
    .map { |line| line.scan(/Step (.+) must be finished before step (.+) can begin./) }
    .map(&:first)

depends_on = {}
descriptions.flatten.uniq.each do
  depends_on[_1] = []
end

descriptions.each do |(point, depends_on_point)|
  depends_on[depends_on_point] << point
end

candidates = descriptions.flatten.uniq.sort
path = []

while !candidates.empty?
  current = candidates.shift
  can_go_to = depends_on[current].all? { |dependency| path.include?(dependency) }
  if can_go_to
    path << current
    candidates.sort!
  else
    candidates << current
  end
end

part1 = path.join

WORKERS_COUNT = 5
candidates = descriptions.flatten.uniq.sort
path = []
workers = []
current_time = 0

Work = Struct.new(:letter, :start) do
  def finish
    cost + start
  end

  private

  def cost
    ('A'..'Z').to_a.index(letter) + 1 + 60
  end
end

while (!candidates.empty? || !workers.empty?)
  can_work = workers.count < WORKERS_COUNT

  if can_work
    can_go_to = candidates.select { |candidate|
      depends_on[candidate].all? { |dependency| path.include?(dependency) }
    }

    if !can_go_to.empty?
      current = can_go_to.sort.first
      candidates.delete(current)
      candidates.sort!
      workers << Work.new(current, current_time)
    else 
      current_time += 1
    end
  else
    current_time += 1
  end

  workers.each { path << _1.letter if _1.finish <= current_time }
  workers.select! { _1.finish > current_time }
end

part2 = current_time

p [part1, part2]
