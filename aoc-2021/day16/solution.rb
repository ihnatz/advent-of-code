def parse_number(binary, i)
  digits = []
  binary.slice(i..).each_slice(5) do |bnum|
    digits << bnum.slice(1..)
    i += 5
    break if bnum[0] == "0"
  end

  [i, digits.join.to_i(2)]
end

def parse_operator(binary, type, i)
  type_id = binary[i]
  value = []
  i += 1

  if type_id == "0"
    length = binary.slice(i..(i + 14)).join.to_i(2)
    i += 15
    finish_i = i + length

    loop do
      i, val = parse_next(binary, i)
      value << val
      break if i == finish_i
    end
  else
    bcount = binary.slice(i..(i + 10))
    i += 11
    count = bcount.join.to_i(2)

    count.times {
      i, val = parse_next(binary, i)
      value << val
    }
  end

  value = case type
  when 0 then value.reduce(&:+)
  when 1 then value.reduce(&:*)
  when 2 then value.min
  when 3 then value.max
  when 5 then value[0] > value[1] ? 1 : 0
  when 6 then value[0] < value[1] ? 1 : 0
  when 7 then value[0] == value[1] ? 1 : 0
  end

  [i, value]
end


packets = File.read("input.txt").strip
binary = packets.chars.each_slice(2).map(&:join).map { |i| i.to_i(16).to_s(2).rjust(8, "0") }.join.chars

$GLOB = []

def parse_next(binary, i)
  version = binary.slice(i..(i + 2)).join.to_i(2)
  i += 3
  type = binary.slice(i..(i + 2)).join.to_i(2)
  i += 3

  $GLOB << version

  i, value = if type == 4
    parse_number(binary, i)
  else
    parse_operator(binary, type, i)
  end

  [i, value]
end

result = parse_next(binary, 0)
answer1 = $GLOB.sum
answer2 = result.last

p [answer1, answer2]
