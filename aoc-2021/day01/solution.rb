example = """
199
200
208
210
200
207
240
269
260
263
""".strip

# input = example
input = File.read('input.txt')
answer1 = input.split("\n").map(&:to_i).each_cons(2).to_a.map { |a, b| b - a }.count(&:positive?)
answer2 = input.split("\n").map(&:to_i).each_cons(3).to_a.map(&:sum).each_cons(2).map { |a, b| b - a }.count(&:positive?)

p [answer1, answer2]
