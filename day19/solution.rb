# frozen_string_literal: true

require 'set'

input = if true
          File.read('input.txt').strip
        else
          File.read('sample.txt').strip
        end

MIN_OVERLAP = 12
SIGNS = [1, -1].product([1, -1]).product([1, -1]).map(&:flatten).freeze

sensors = input.split("\n\n").map do |desc|
  desc.split("\n").drop(1).map { |desc| desc.split(',').map(&:to_i) }
end

def orientations(coordinates)
  coordinates
    .permutation
    .to_a
    .product(SIGNS)
    .map { |a, b| [a[0] * b[0], a[1] * b[1], a[2] * b[2]] }
end

def assign(idx, scanners, beacons, sensors, tried_cache)
  possibles = beacons - tried_cache[idx]
  groups = sensors[idx].map { |sensor| orientations(sensor) }.transpose

  groups.each do |candidates|
    candidates.each do |candidate|
      possibles.each do |beacon|
        d = beacon.zip(candidate).map { |x| x.reduce(:-) }
        tried = Set.new(candidates.map { |x| [x[0] + d[0], x[1] + d[1], x[2] + d[2]] })

        overlap = (tried & beacons).length >= MIN_OVERLAP

        next unless overlap

        beacons.merge(tried)
        scanners[idx] = d
        return true
      end

      tried_cache[idx] |= possibles
    end
  end

  false
end

# scanners = { 0 => [0, 0, 0] }
# beacons = Set.new(sensors[0])
# tried_cache = Hash.new { Set.new }
# not_placed = Set.new((1..(sensors.length - 1)).to_a)

# loop do
#   puts "#{not_placed.length} LEFT"

#   break if not_placed.empty?

#   not_placed.each do |idx|
#     assigned = assign(idx, scanners, beacons, sensors, tried_cache)
#     if assigned
#       not_placed.delete(idx)
#       break
#     end
#   end
# end

# p scanners
# answer1 = beacons.size

def md(a, b)
  a.zip(b).map { _1.reduce(:-).abs }.sum
end

PRE_CACL = {0=>[0, 0, 0], 2=>[-28, 1245, -161], 18=>[-18, 1355, -1280], 7=>[-12, 2400, -1318], 23=>[-1075, 1190, -1385], 10=>[-2449, 1277, -1238], 15=>[-2348, 173, -1313], 1=>[-2380, 15, -13], 4=>[-1078, 63, 1010], 11=>[-1233, -1211, 1144], 12=>[-1092, 1288, 1125], 8=>[-1224, 2573, 1061], 24=>[1163, 26, -170], 26=>[-1105, 28, -1236], 27=>[-1254, 90, -158], 30=>[-2428, 1249, 1069], 31=>[1146, -1193, -28], 32=>[-2450, -1024, -26], 3=>[-2290, -2266, -141], 6=>[-2269, -3556, -95], 9=>[-2385, -3457, 1117], 13=>[-2339, -3488, 2394], 5=>[-3472, -3589, 2361], 17=>[-2334, -4684, 1017], 19=>[-1131, -2278, -172], 20=>[-2337, -2411, 1197], 21=>[-1256, -3495, 2220], 34=>[-2369, -4811, -22], 35=>[-1144, -3615, -89], 36=>[-3547, 0, -79], 16=>[-4753, 30, -166], 28=>[-3532, 97, 1132], 14=>[-3560, 131, 2245], 25=>[-4732, -17, 2315], 29=>[-4722, 31, 1198], 33=>[-6042, 159, -182], 22=>[-5936, -1062, -10]}

answer2 = PRE_CACL.values.product(PRE_CACL.values).map do |(a, b)|
  md(a, b)
end.max

p [answer2]
