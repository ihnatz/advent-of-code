puzzle1 = File
  .read('input.txt')
  .split("\n\n")
  .map { _1.gsub(/\s/, '')}
  .map(&:chars)
  .map(&:uniq)
  .sum(&:count)

puzzle2 = File
  .read('input.txt')
  .split("\n\n")
  .map { _1.split("\n") }
  .map { _1.map(&:chars) }
  .flat_map { _1.inject(:&) }
  .count

p [puzzle1, puzzle2]
