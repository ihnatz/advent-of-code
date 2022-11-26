N = 890691

def part1
  scores = [3, 7]
  p1, p2 = 0, 1
  recipes = 2

  loop do
    score = scores[p1] + scores[p2]
    s1 = score / 10
    s2 = score % 10
    if s1 > 0
      scores << s1
      recipes += 1
      break if recipes == N + 10
    end
    scores << s2
    recipes += 1
    break if recipes == N + 10

    p1 = (p1 + (scores[p1] + 1)) % scores.size
    p2 = (p2 + (scores[p2] + 1)) % scores.size
  end

  scores.last(10).join
end

EXPECTED = N.to_s.chars.map(&:to_i)

def part2
  scores = [3, 7]
  p1, p2 = 0, 1
  recipes = 2
  tail = [3, 7]

  loop do
    # p recipes if (recipes % 10_000) == 0
    score = scores[p1] + scores[p2]
    s1 = score / 10
    s2 = score % 10

    if s1 > 0
      scores << s1
      tail << s1
      tail.shift if tail.size > EXPECTED.size
      recipes += 1
      break if tail == EXPECTED
    end

    scores << s2
    tail << s2
    tail.shift if tail.size > EXPECTED.size
    recipes += 1
    break if tail == EXPECTED

    p1 = (p1 + (scores[p1] + 1)) % scores.size
    p2 = (p2 + (scores[p2] + 1)) % scores.size
  end

  recipes - EXPECTED.size
end

p [part1, part2]
