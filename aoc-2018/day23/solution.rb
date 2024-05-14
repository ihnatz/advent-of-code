input = File.read("input.txt")
nanobots = input.split("\n").map(&:chomp)

def dist(p1, p2)
  p1.zip(p2).map { _1.reduce(:-).abs }.sum
end

def dot?(cube)
  (cube[0][1] - cube[0][0]) *
    (cube[1][1] - cube[1][0]) *
    (cube[2][1] - cube[2][0]) == 1
end

def edge_dist(x, xs)
  lower, upper = xs
  return lower - x if x < lower
  return x - upper + 1 if x > upper
  0
end

def within_range(bot, cube)
  edge_dist(bot[0], cube[0]) +
    edge_dist(bot[1], cube[1]) +
    edge_dist(bot[2], cube[2]) <= bot.last
end

nanobots.map! { |line| line.scan(/-*\d+/).map(&:to_i) }

max_bot = nanobots.max_by(&:last)
max_bot_r = max_bot.last

part1 = nanobots.count { |bot| dist(bot, max_bot) < max_bot_r }

def split(cube)
  xs, ys, zs = cube

  mid_xs = (xs[0] + xs[1]) / 2
  mid_ys = (ys[0] + ys[1]) / 2
  mid_zs = (zs[0] + zs[1]) / 2

  [
    [[xs[0], mid_xs], [mid_xs + 1, xs[1]]],
    [[ys[0], mid_ys], [mid_ys + 1, ys[1]]],
    [[zs[0], mid_zs], [mid_zs + 1, zs[1]]]
  ].inject(&:product).map(&:flatten).map {
    [
      [_1[0], _1[1]],
      [_1[2], _1[3]],
      [_1[4], _1[5]]
    ]
  }
end

border = nanobots.flatten(1).map(&:abs).max
cube = [[-border, border], [-border, border], [-border, border], nanobots.count]

q = [cube]
best = nil

until q.empty?
  q.sort_by!(&:last)
  current = q.pop

  if dot?(current)
    best = current if !best || current.last > best.last
  else
    split(current).each do |cube|
      count = nanobots.count { within_range(_1, cube) }
      q << [*cube, count] if !best || best.last < count
    end
  end
end

part2 = best.first(3).map(&:first).sum
p [part1, part2]
