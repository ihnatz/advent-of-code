REVERSE_SYMBOLS = {
  "\n" => 10,
  "."  => 46,
  "#"  => 35,
  '^'  => 94
}

def default_map
  inputs = """
..#..........
..#..........
#######...###
#.#...#...#.#
#############
..#...#...#..
..#####...^..
"""

  inputs.chars.map { |char|
    REVERSE_SYMBOLS.fetch(char)
  }
end
