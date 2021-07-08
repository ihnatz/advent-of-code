# input = """
# 10 ORE => 10 A
# 1 ORE => 1 B
# 7 A, 1 B => 1 C
# 7 A, 1 C => 1 D
# 7 A, 1 D => 1 E
# 7 A, 1 E => 1 FUEL
# """

# input = """9 ORE => 2 A
# 8 ORE => 3 B
# 7 ORE => 5 C
# 3 A, 4 B => 1 AB
# 5 B, 7 C => 1 BC
# 4 C, 1 A => 1 CA
# 2 AB, 3 BC, 4 CA => 1 FUEL
# """

# input = """171 ORE => 8 CNZTR
# 7 ZLQW, 3 BMBT, 9 XCVML, 26 XMNCP, 1 WPTQ, 2 MZWV, 1 RJRHP => 4 PLWSL
# 114 ORE => 4 BHXH
# 14 VRPVC => 6 BMBT
# 6 BHXH, 18 KTJDG, 12 WPTQ, 7 PLWSL, 31 FHTLT, 37 ZDVW => 1 FUEL
# 6 WPTQ, 2 BMBT, 8 ZLQW, 18 KTJDG, 1 XMNCP, 6 MZWV, 1 RJRHP => 6 FHTLT
# 15 XDBXC, 2 LTCX, 1 VRPVC => 6 ZLQW
# 13 WPTQ, 10 LTCX, 3 RJRHP, 14 XMNCP, 2 MZWV, 1 ZLQW => 1 ZDVW
# 5 BMBT => 4 WPTQ
# 189 ORE => 9 KTJDG
# 1 MZWV, 17 XDBXC, 3 XCVML => 2 XMNCP
# 12 VRPVC, 27 CNZTR => 2 XDBXC
# 15 KTJDG, 12 BHXH => 5 XCVML
# 3 BHXH, 2 VRPVC => 7 MZWV
# 121 ORE => 7 VRPVC
# 7 XCVML => 6 RJRHP
# 5 BHXH, 4 VRPVC => 5 LTCX
# """

input = File.read("input.txt")

def quantify(desc)
  num, name = desc.split(" ")
  [name, num.to_i]
end

transformations = input
  .strip.split("\n")
  .map { |line| line.split(" => ") }
  .map { |(from, to)| [from.split(", ").map { |it| quantify(it) } , quantify(to)] }
  .map { |(from, to)| [to[0], [from, to[1]]] }
  .to_h

def calculate(transformations, required)
  while required.any? { |name, quantity| name != "ORE" && quantity > 0 }
    required.entries.each do |name, quantity|
      next if name == "ORE"

      inputs, need_quantity = transformations.fetch(name)
      batches = (quantity.to_f / need_quantity).ceil

      inputs.each do |from_name, from_quantity|
        required[from_name] ||= 0
        required[from_name] += (from_quantity * batches)
      end

      required[name] -= (batches * need_quantity)
    end

    required.each do |name, quantity|
      required.delete(name) if quantity == 0
    end
  end

  required["ORE"]
end

answer1 = calculate(transformations, "FUEL" => 1)

limit = 1e12
min, max = 0, limit

while max - min > 1
  guess = min + (max - min) / 2
  produced = calculate(transformations, "FUEL" => guess)
  if produced > limit
    max = guess
  else
    min = guess
  end
end

answer2 = min.ceil

p [answer1, answer2]
