PREABMLE_LENGTH = 25

input = File.read('input.txt').split("\n").map(&:to_i)

preabmle = input.slice(0, PREABMLE_LENGTH)
puzzle1 = input.drop(PREABMLE_LENGTH).each { |next_number|
  break next_number unless preabmle.combination(2).map(&:sum).any? { _1 == next_number }
  preabmle.shift
  preabmle.push(next_number)
}

puzzle2 = input.length.times { |i|
  window_size = 1
  sequence = loop {
    window = input.drop(i).slice(0, window_size)
    break window if window.sum == puzzle1
    break if window.sum > puzzle1
    window_size += 1
  }
  break sequence.minmax.sum if sequence
}

p [puzzle1, puzzle2]
