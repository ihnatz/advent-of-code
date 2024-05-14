input = File.read("input.txt").split("\n")

def appears_count(input, ingridients)
  all_ingridients = input.flat_map { _1.split(" (").first.split(" ") }
  all_ingridients.tally.slice(*ingridients).values.sum
end

def uniq_allergens(candidates)
  total = candidates.dup

  loop do
    break if total.values.all?(&:one?)

    detected = total.select { |k, v| v.size == 1 }
    in_process = total.slice(*(total.keys - detected.keys))

    in_process.each { |k, v| total[k] = v - detected.values.flatten }
  end

  total
end

mapping = input.map {
  ingredients, allergens = _1.split(" (contains ")
  allergens.gsub!(")", "")
  [ingredients.split(" "),  allergens.split(", ")]
}.to_h

candidates = {}
mapping.each do |ingredients, allergens|
  allergens.each do |allergen|
    candidates[allergen] ||= ingredients
    candidates[allergen]  &= ingredients
  end
end

puzzle1 = appears_count(input, mapping.keys.flatten.uniq - candidates.values.flatten.uniq)
puzzle2 = uniq_allergens(candidates).sort_by { _1 }.map(&:last).flatten.join(',')

p [puzzle1, puzzle2]
