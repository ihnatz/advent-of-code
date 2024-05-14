def valid?(password, extra: false)
  return false unless password.each_cons(2).any? { |(a, b)| a == b }
  return false unless password.each_cons(2).all? { |(a, b)| a <= b }
  if extra
    groups = password.each_cons(2).to_a.inject([1]) { |r, x| x[0] == x[1] ? r[-1] += 1 : r << 1; r }
    return false unless groups.any? { |it| it == 2 }
  end
  return true
end

def count(extra)
  start = [1, 3, 4, 5, 6, 4]
  finish = [5, 8, 5, 1, 5, 9]

  counter = 0

  while start != finish do
    start[-1] += 1

    (0..5).reverse_each do |idx|
      next if start[idx] < 10
      start[idx] -= 10
      start[idx - 1] += 1
    end

    counter +=1 if valid?(start, extra: extra)
  end

  counter
end

answer1 = count(false)
answer2 = count(true)

p [answer1, answer2]
