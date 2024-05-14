input = File.read("input.txt").split("\n")

def modinv(a, m) # compute a^-1 mod m if possible
  raise "NO INVERSE - #{a} and #{m} not coprime" unless a.gcd(m) == 1
  return m if m == 1
  m0, inv, x0 = m, 1, 0
  while a > 1
    inv -= (a / m) * x0
    a, m = m, a % m
    inv, x0 = x0, inv
  end
  inv += m0 if inv < 0
  inv
end

def slow(commands, deck, int)
  commands.each do |command|
    deck = case command
    when /deal with increment/
      n = command.split(" ").last.to_i
      count = deck.length
      deck.each_with_index.map { |_, i| deck[(i * modinv(n, count)) % count]}
    when /deal into new stack/
      deck.reverse
    when /cut/
      n = command.split(" ").last.to_i
      deck.rotate(n)
    end
  end
  deck.find_index(int)
end

def fast(commands, count, int, times)
  increment_mul = 1
  offset_diff = 0

  commands.each do |command|
    deck = case command
    when /deal into new stack/
      increment_mul *= -1
      increment_mul %= count
      offset_diff += increment_mul
      offset_diff %= count
    when /deal with increment/
      n = command.split(" ").last.to_i
      increment_mul *= modinv(n, count)
      increment_mul %= count
    when /cut/
      n = command.split(" ").last.to_i
      offset_diff += n * increment_mul
      offset_diff %= count
    end
  end

  increment = increment_mul.pow(times, count)
  offset = offset_diff * (1 - increment) * modinv((1 - increment_mul) % count, count)
  (offset + int * increment) % count
end


cards = (0..10_006).to_a
int = 2019
answer_1 = slow(input, cards, int)

count = 119315717514047
times = 101741582076661
int = 2020
answer_2 = fast(input, count, int, times)

p [answer_1, answer_2]
