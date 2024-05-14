input = "3,4,3,1,2"
input = File.read("input.txt").chomp


def answer_1(input)
  generation = 7
  new_lanternfish = 8
  state = input.split(",").map(&:to_i)
  days = 80

  days.times do |day|
    new_generation = []
    state.each_with_index do |lanternfish, index|
      if lanternfish == 0
        state[index] = generation - 1
        new_generation << new_lanternfish
      else
        state[index] = lanternfish - 1
      end
    end
    state += new_generation
  end

  state.length
end

def answer_2(input)
  generation = 7
  new_lanternfish = 8
  state = input.split(",").map(&:to_i)
  days = 80

  state = input.split(",").map(&:to_i)
  generations = [0, 0, 0, 0, 0, 0, 0, 0, 0]
  state.each do |lanternfish|
    generations[lanternfish] += 1
  end

  days = 256

  days.times do |day|
    new_generations = [0, 0, 0, 0, 0, 0, 0, 0, 0]
    new_generations[8] = generations[0]
    new_generations[generation - 1] += generations[0]
    (0..7).each do |index|
      new_generations[index] += generations[index + 1]
    end
    generations = new_generations
  end

  generations.sum
end

p [answer_1(input), answer_2(input)]
