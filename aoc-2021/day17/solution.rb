# input = "target area: x=20..30, y=-10..-5"
input = "target area: x=25..67, y=-260..-200"

area_x, area_y =
  input
    .sub("target area: ", "")
    .split(", ")
    .map { |cord| cord.sub(/(x|y)=/, '') }
    .map { |cord| cord.split("..").map(&:to_i) }
    .map { |cord| Range.new(*cord) }

def check(vel_x, vel_y, area_x, area_y)
  x, y, ys = 0, 0, []

  1000.times do
    x += vel_x
    y += vel_y
    ys << y

    return(ys.max) if area_y.include?(y) && area_x.include?(x)

    vel_x = vel_x == 0 ? vel_x : vel_x > 0 ? vel_x - 1 : vel_x + 1
    vel_y -= 1
  end

  false
end

res = []
(0..area_x.last).each do |pos_x|
  (area_y.first..area_y.first.abs).each do |pos_y|
    z = check(pos_x, pos_y, area_x, area_y)
    res << z if z
  end
end
answer1 = res.max
answer2 = res.count

p [answer1, answer2]
