input = '464 players; last marble is worth 71730 points'

class Marble
  def initialize(number:)
    @number = number
  end

  attr_reader :number
  attr_accessor :left, :right
end

def pp(zero, current)
  arr = [zero.number]
  t_zero = zero
  while t_zero.right != zero
    if t_zero.right == current
      arr << "(#{t_zero.right.number})"
    else
      arr << t_zero.right.number.to_s
    end
    t_zero = t_zero.right 
  end
  arr.join(' ')
end

def scores(players, max_number)
  marble = Marble.new(number: 0)
  marble.left = marble
  marble.right = marble

  zero = marble
  scores = Array.new(players + 1, 0)

  next_number = 0

  loop do
    break if next_number == max_number

    next_number += 1
    player = ((next_number - 1) % players) + 1

    if next_number % 23 != 0
      next_marble = Marble.new(number: next_number)

      next_1 = marble.right
      next_2 = marble.right.right

      next_1.right = next_marble
      next_2.left  = next_marble

      next_marble.left = next_1
      next_marble.right = next_2

      marble = next_marble
    else
      to_remove = marble.left.left.left.left.left.left.left

      scores[player] += next_number
      scores[player] += to_remove.number

      marble = to_remove.right

      l = to_remove.left
      r = to_remove.right

      to_remove.left.right = r
      to_remove.right.left = l     
    end

    # p [player, pp(zero, marble)]
  end

  scores
end

# ------------------------------------

players, max_number = input.scan(/\d+/).map(&:to_i)
# players, max_number = 30, 5807
# players, max_number = 10, 1618
# players, max_number = 9, 25

part1 = scores(players, max_number).max
part2 = scores(players, max_number * 100).max
p [part1, part2]