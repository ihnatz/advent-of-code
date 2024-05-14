player1, player2 = File.read('input.txt').split("\n\n")
player1, player2 = [player1, player2].map { _1.split("\n").drop(1).map(&:to_i) }

def combat(player1, player2)
  loop {
    break if [player1, player2].any?(&:empty?)
    card1 = player1.shift
    card2 = player2.shift

    if card1 > card2
      player1 << card1 << card2
    else
      player2 << card2 << card1
    end
  }
  [player1, player2]
end

def recursive_combat(player1, player2, id = 0)
  rounds = []

  result = loop {
    break(:ok) if [player1, player2].any?(&:empty?)
    break(:recursive) if rounds.any? { |(prev1, prev2)| prev1 == player1 && prev2 == player2 }

    rounds << [player1.dup, player2.dup]

    card1 = player1.shift
    card2 = player2.shift

    if player1.count >= card1 && player2.count >= card2
      subgame_result = recursive_combat(
        player1.slice(0, card1),
        player2.slice(0, card2),
        id + 1
      )
      if subgame_result.first.length > 0
        player1 << card1 << card2
      else
        player2 << card2 << card1
      end
    else
      if card1 > card2
        player1 << card1 << card2
      else
        player2 << card2 << card1
      end
    end
  }

  if result == :ok
    [player1, player2]
  else
    [player1, []]
  end
end

def scores(winner_deck)
  winner_deck.reverse.map.with_index { _1 * (_2 + 1) }.sum
end

puzzle1 = combat(player1.dup, player2.dup).then {
  scores(_1.reject(&:empty?).first)
}

puzzle2 = recursive_combat(player1, player2).then {
  scores(_1.reject(&:empty?).first)
}

p [puzzle1, puzzle2]
