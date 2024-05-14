lines = File.read('input.txt').split("\n")

def recursive_fuel(mass)
  return 0 if mass <= 0
  [fuel(mass), 0].max + recursive_fuel(fuel(mass))
end

def fuel(mass)
  (mass / 3.0 - 2).to_i
end

answer1 = lines.map { |mass| fuel(mass.to_i) }.sum
answer2 = lines.map { |mass| recursive_fuel(mass.to_i) }.sum

p [answer1, answer2]
