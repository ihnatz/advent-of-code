input = if true
  """
Player 1 starting position: 8
Player 2 starting position: 9
  """.strip
else
  """
Player 1 starting position: 4
Player 2 starting position: 8
  """.strip
end

p1 = input.split("\n").first.split(" ").last.to_i
p2 = input.split("\n").last.split(" ").last.to_i

def dice_enum
  Enumerator.new do |y|
    loop do
      (1..100).each { |i| y << i }
    end
  end
end

def part1(p1, p2)
  dice1 = dice_enum
  s1 = 0
  s2 = 0
  times = 0

  loop {
    next_dice = [dice1.next, dice1.next, dice1.next].sum
    times += 3
    p1 = (p1 + next_dice) % 10
    s1 += p1 + 1

    return s2 * times if s1 >= 1000

    next_dice = [dice1.next, dice1.next, dice1.next].sum
    times += 3
    p2 = (p2 + next_dice) % 10
    s2 += p2 + 1

    return s1 * times if s2 >= 1000
  }
end

answer1 = part1(p1 - 1, p2 - 1)

def part2(p1, p2)
  search(p1 - 1, p2 - 1, 0, 0).max
end

MEM = {}
ROLLS = [1, 2, 3].product([1, 2, 3]).product([1, 2, 3]).map(&:flatten).map(&:sum)

def search(p1, p2, s1, s2)
  MEM[[p1, p2, s1, s2]] ||= begin
    return [1, 0] if s1 >= 21
    return [0, 1] if s2 >= 21

    ROLLS.map { |roll|
      new_p1 = (p1 + roll) % 10
      search(p2, new_p1, s2, s1 + new_p1 + 1)
    }.transpose.map(&:sum).reverse
  end
end

answer2 = part2(p1, p2)

p [answer1, answer2]
