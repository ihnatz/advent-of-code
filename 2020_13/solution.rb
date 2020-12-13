OUT_OF_SERVICE = "x"

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

def find_earlies_time(buses, start = 0, step = 1)
  return [buses.first, buses.first] if buses.length == 1
  start, step = find_earlies_time(buses.slice(0..-2), start, step)

  next_tick = start

  earliest_timestamp = loop {
    break(next_tick) if valid?(buses, next_tick)
    next_tick += step
  }

  max_step = buses.select { |bus| bus != OUT_OF_SERVICE }.inject(&:*)
  [earliest_timestamp, max_step]
end

puzzle2 = find_earlies_time(buses).first

p [puzzle1, puzzle2]
