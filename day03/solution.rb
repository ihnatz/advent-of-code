input = "
00100
11110
10110
10111
10101
01111
00111
11100
10000
11001
00010
01010
".strip
input = File.read("input.txt").strip

values = input.split("\n")
lb, hb = [], []
values.first.size.times do |i|
  x = values.map { |z| z[i] }.group_by { |v| v }
  if x['0'].size > x['1'].size
    hb << 0
    lb << 1
  else
    hb << 1
    lb << 0
  end
end

answer1 = hb.join.to_i(2) * lb.join.to_i(2)


values = input.split("\n")
size = values.first.size.times
lb, hb = [], []
current_index = 0
while values.size > 1 do
  grouped_bits = values.map { |x| x[current_index] }.group_by { |v| v }
  most_common = grouped_bits["1"]&.length.to_i >= grouped_bits["0"]&.length.to_i ? "1" : "0"
  values.reject! { |x| x[current_index] != most_common }
  current_index += 1
end

a1 = values.join.to_i(2)

values = input.split("\n")
size = values.first.size.times
lb, hb = [], []
current_index = 0
while values.size > 1 do
  grouped_bits = values.map { |x| x[current_index] }.group_by { |v| v }
  most_common = grouped_bits["1"]&.length.to_i >= grouped_bits["0"]&.length.to_i ? "0" : "1"
  values.reject! { |x| x[current_index] != most_common }
  current_index += 1
end

a2 = values.join.to_i(2)

answer2 = a1 * a2

p [answer1, answer2]
