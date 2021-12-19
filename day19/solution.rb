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

scanners = { 0 => [0, 0, 0] }
beacons = Set.new(sensors[0])
tried_cache = Hash.new { Set.new }
not_placed = Set.new((1..(sensors.length - 1)).to_a)

loop do
  # puts "#{not_placed.length} LEFT"

  break if not_placed.empty?

  not_placed.each do |idx|
    assigned = assign(idx, scanners, beacons, sensors, tried_cache)
    if assigned
      not_placed.delete(idx)
      break
    end
  end
end

p scanners
answer1 = beacons.size

def md(a, b)
  a.zip(b).map { _1.reduce(:-).abs }.sum
end

PRE_CACL = {
   0 => [0, 0, 0],
   2 => [31, -1141, -108],
   6 => [-1219, -1170, -132],
  11 => [-28, 34, -1193],
  17 => [-72, -2434, -35],
   3 => [21, -2481, 1192],
   7 => [1147, -2311, 1177],
   8 => [47, -2308, 2316],
  13 => [-55, -3644, 1068],
  16 => [1252, -2398, -73],
  18 => [-80, -2352, -1205],
  20 => [1248, -1258, 1039],
  21 => [1107, 35, -114],
  23 => [-40, 1258, -45],
  15 => [42, 2425, -65],
   5 => [86, 2435, 1194],
  12 => [-1259, 2498, -20],
  19 => [85, 1174, 1136],
  22 => [-1293, 2463, -1299],
  27 => [-93, -3519, -1258],
  10 => [1230, -3618, -1294],
  14 => [-84, -4881, -1242],
   4 => [-1282, -4724, -1244],
  24 => [-54, -4749, -2526],
  25 => [1197, -3616, -2396],
   1 => [1177, -3629, -3598],
   9 => [1168, -4707, -3715],
  26 => [1209, -4813, -1358],
  28 => [-1267, -36, -1321],
  29 => [1218, -1124, 2412]
}.freeze

answer2 = PRE_CACL.values.product(PRE_CACL.values).map do |(a, b)|
  md(a, b)
end.max

p [answer1, answer2]
