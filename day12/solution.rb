LOG = false

Moon = Struct.new(:pos, :vel) do
  def pot
    pos.x.abs + pos.y.abs + pos.z.abs
  end

  def kin
    vel.x.abs + vel.y.abs + vel.z.abs
  end

  def total
    pot * kin
  end
end
Coordinates = Struct.new(:x, :y, :z)

def to_sign(val1, val2)
  val = val2 - val1

  case
  when val > 0 then 1
  when val < 0 then -1
  else 0
  end
end

# Ex.1:
#
# STEPS = 10
# moon1 = Moon.new(Coordinates.new(-1, 0, 2), Coordinates.new(0, 0, 0))
# moon2 = Moon.new(Coordinates.new(2, -10, -7), Coordinates.new(0, 0, 0))
# moon3 = Moon.new(Coordinates.new(4, -8, 8), Coordinates.new(0, 0, 0))
# moon4 = Moon.new(Coordinates.new(3, 5, -1), Coordinates.new(0, 0, 0))

# Ex.2:
#
# STEPS = 100
# moon1 = Moon.new(Coordinates.new(-8,-10,0), Coordinates.new(0, 0, 0))
# moon2 = Moon.new(Coordinates.new(5, 5,  10), Coordinates.new(0, 0, 0))
# moon3 = Moon.new(Coordinates.new(2, -7, 3), Coordinates.new(0, 0, 0))
# moon4 = Moon.new(Coordinates.new(9, -8, -3), Coordinates.new(0, 0, 0))

# INPUT:
#
STEPS = 1000
moon1 = Moon.new(Coordinates.new(-4,  -9,  -3), Coordinates.new(0, 0, 0))
moon2 = Moon.new(Coordinates.new(-13, -11, 0), Coordinates.new(0, 0, 0))
moon3 = Moon.new(Coordinates.new(-17, -7,  15), Coordinates.new(0, 0, 0))
moon4 = Moon.new(Coordinates.new(-16,  4,  2), Coordinates.new(0, 0, 0))

moons = [moon1, moon2, moon3, moon4]

def tick(moons)
  moons.combination(2).each do |(m1, m2)|
    m1.vel.x += to_sign(m1.pos.x, m2.pos.x)
    m2.vel.x -= to_sign(m1.pos.x, m2.pos.x)

    m1.vel.y += to_sign(m1.pos.y, m2.pos.y)
    m2.vel.y -= to_sign(m1.pos.y, m2.pos.y)

    m1.vel.z += to_sign(m1.pos.z, m2.pos.z)
    m2.vel.z -= to_sign(m1.pos.z, m2.pos.z)
  end

  moons.each do |moon|
    moon.pos.x += moon.vel.x
    moon.pos.y += moon.vel.y
    moon.pos.z += moon.vel.z
  end

  moons
end

def answer1(moons)
  STEPS.times do |i|
    puts "After #{i + 1} steps:" if LOG
    tick(moons)
    moons.each do |m|
      puts "pos=<x=#{m.pos.x}, y=#{m.pos.y}, z=#{m.pos.z}>, vel=<x=#{m.vel.x}, y=#{m.vel.y}, z=#{m.vel.z}>" if LOG
    end
    puts if LOG
  end

  puts "Energy after #{STEPS} steps:" if LOG

  moons.each do |m|
    puts "pot: #{m.pot}; kin: #{m.kin}; total: #{m.total}" if LOG
  end

  puts if LOG
  puts "Sum of total energy: #{moons.sum(&:total)}"
end

# answer1(moons)

i = 0
cycles = Coordinates.new(nil)

loop {
  i += 1

  prev_moons = moons.map(&:pos).map(&:dup)
  tick(moons)

  cycles.x ||= i if moons.map { |m| m.pos.x } == prev_moons.map { |m| m.x } && i > 1
  cycles.y ||= i if moons.map { |m| m.pos.y } == prev_moons.map { |m| m.y } && i > 1
  cycles.z ||= i if moons.map { |m| m.pos.z } == prev_moons.map { |m| m.z } && i > 1

  if cycles.none?(&:nil?)
    p cycles
    p cycles.inject(:*)
    break
  end
}
