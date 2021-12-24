input = if true
  File.read("input.txt")
else
  File.read("sample.txt")
end.strip

ADD = -> (a, b) {a + b}
MUL = -> (a, b) {a * b}
DIV = -> (a, b) {a / b}
MOD = -> (a, b) {a % b}
EQL = -> (a, b) {a == b ? 1 : 0}

def to_enum(number)
  Enumerator.new do |y|
    number.to_s.chars.each do |digit|
      y << digit.to_i
    end
  end
end

def run(input, cin)
  mem = Hash.new(0)
  current_step = 0
  input.split("\n").map { |instruction|
    command, *args = instruction.split(" ")


    second_arg = if command == "inp"
      current_step += 1
      nil
    else
      args[1].match?(/\d+/) ? args[1].to_i : mem[args[1]]
    end


    case command
    when "inp" then mem[args[0]] = cin.next
    when "add" then mem[args[0]] = ADD.call(mem[args[0]], second_arg)
    when "mul" then mem[args[0]] = MUL.call(mem[args[0]], second_arg)
    when "div" then mem[args[0]] = DIV.call(mem[args[0]], second_arg)
    when "mod" then mem[args[0]] = MOD.call(mem[args[0]], second_arg)
    when "eql" then mem[args[0]] = EQL.call(mem[args[0]], second_arg)
    end
  }
  mem["z"]
end


candidates = []

(1..9).reverse_each do |a|
  (1..9).reverse_each do |b|
    (1..9).reverse_each do |c|
      d = c - 3
      next if d <= 0 || d > 9
      (1..9).reverse_each do |e|
        (1..9).reverse_each do |f|
          g = f + 3
          next if g <= 0 || g > 9
          h = e + 2
          next if h <= 0 || h > 9
          (1..9).reverse_each do |i|
            j = i - 5
            next if j <= 0 || j > 9
            (1..9).reverse_each do |k|
              l = k - 1
              next if l <= 0 || l > 9
              m = b + 7
              next if m <= 0 || m > 9
              n = a - 8
              next if n <= 0 || n > 9

              number = [a, b, c, d, e, f, g, h, i, j, k, l, m, n]
              result = run(input, number.each)
              candidates << number if result == 0
            end
          end
        end
      end
    end
  end
end

answer1, answer2 = candidates.map { |z| z.map(&:to_s).join.to_i }.minmax.reverse
p [answer1, answer2]
