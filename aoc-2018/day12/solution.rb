state = '.#####.##.#.##...#.#.###..#.#..#..#.....#..####.#.##.#######..#...##.#..#.#######...#.#.#..##..#.#.#'.chars

RULES = {
  '#..#.' => '.',
  '##...' => '#',
  '#....' => '.',
  '#...#' => '#',
  '...#.' => '.',
  '.#..#' => '#',
  '#.#.#' => '.',
  '.....' => '.',
  '##.##' => '#',
  '##.#.' => '#',
  '###..' => '#',
  '#.##.' => '.',
  '#.#..' => '#',
  '##..#' => '#',
  '..#.#' => '#',
  '..#..' => '.',
  '.##..' => '.',
  '...##' => '#',
  '....#' => '.',
  '#.###' => '#',
  '#..##' => '#',
  '..###' => '#',
  '####.' => '#',
  '.#.#.' => '#',
  '.####' => '.',
  '###.#' => '#',
  '#####' => '#',
  '.#.##' => '.',
  '.##.#' => '.',
  '.###.' => '.',
  '..##.' => '.',
  '.#...' => '#',
}

def next_generation(state, start)
  start += 2

  new_generation = ('....'.chars + state + '....'.chars).each_cons(5).map.with_index { |i, idx|
    RULES.fetch(i.join, '.')
  }

  ltail = new_generation.index("#")
  rtail = new_generation.rindex("#")

  [new_generation.slice(ltail..rtail), start - ltail]
end

PART_0 = 20
PART_1 = 20_000
PART_2 = 50_000_000_000

start = 0
part1 = nil
PART_1.times do |i|
  part1 = state.map.with_index { |chr, idx| chr == '#' ? idx - start : nil }.compact.sum if i == PART_0
  state, start = next_generation(state, start)
end

idxs = state.map.with_index { |chr, idx| chr == '#' ? idx - start : nil }.compact
part2 = idxs.map { |val| val + (PART_2 - PART_1) }.sum

p [part1, part2]
