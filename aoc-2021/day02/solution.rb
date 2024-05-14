input = "
forward 5
down 5
forward 8
up 3
down 8
forward 2
".strip
# input = File.read("input.txt")

hp, vp = 0, 0
input.split("\n").each do |line|
  value = line.split(" ").last.to_i
  case line
  when /up/
    vp -= value
  when /down/
    vp += value
  when /forward/
    hp += value
  end
end
answer1 = hp * vp

aim, hp, vp = 0, 0, 0
input.split("\n").each do |line|
  value = line.split(" ").last.to_i
  case line
  when /up/
    aim -= value
  when /down/
    aim += value
  when /forward/
    hp += value
    vp += value * aim
  end
end
answer2 = hp * vp

p [answer1, answer2]
