OUT_OF_SERVICE = "x"

def extended_gcd(a, b)
  last_remainder, remainder = a.abs, b.abs
  x, last_x, y, last_y = 0, 1, 1, 0
  while remainder != 0
    last_remainder, (quotient, remainder) = remainder, last_remainder.divmod(remainder)
    x, last_x = last_x - quotient*x, x
    y, last_y = last_y - quotient*y, y
  end

  return last_remainder, last_x * (a < 0 ? -1 : 1)
end

def invmod(e, et)
  g, x = extended_gcd(e, et)
  raise 'The maths are broken!' if g != 1
  x % et
end

def crt(system)
  n = system.map(&:last).inject(:*)
  ys = system.map(&:last).map { |it| n / it }
  zs = system.map(&:last).zip(ys).map { |a, m| invmod(m, a) }
  x = system.map(&:first).zip(ys, zs).map { |it| it.inject(&:*) }.sum % n
  [x, n]
end

input = File.read("input.txt")
timestamp, buses = input.split("\n")
buses = buses.split(",").map { |description|
  description == OUT_OF_SERVICE ? description : description.to_i
}

next_tick = timestamp.to_i + 1
bus_id = loop {
  divider = buses.select { |bus| bus != OUT_OF_SERVICE }.find { next_tick % _1 == 0 }
  break divider unless divider.nil?
  next_tick += 1
}

puzzle1 = (next_tick - timestamp.to_i) * bus_id

def valid?(buses, timestamp)
  departures_times = buses.length.times.map { |offset| timestamp + offset }
  buses.zip(departures_times).all? { |(bus_id, departure_timestamp)|
    next(true) if bus_id == OUT_OF_SERVICE
    departure_timestamp % bus_id == 0
  }
end

def find_earliest_time(buses, start = 0, step = 1)
  return [buses.first, buses.first] if buses.length == 1
  start, step = find_earliest_time(buses.slice(0..-2), start, step)

  next_tick = start

  earliest_timestamp = loop {
    break(next_tick) if valid?(buses, next_tick)
    next_tick += step
  }

  max_step = buses.select { |bus| bus != OUT_OF_SERVICE }.inject(&:*)
  [earliest_timestamp, max_step]
end

puzzle2 = crt(buses.map.with_index { |val, idx|
  next if val == OUT_OF_SERVICE
  [idx, val.to_i]
}.compact).reverse.inject(:-)

puzzle2 = find_earliest_time(buses).first

p [puzzle1, puzzle2]
