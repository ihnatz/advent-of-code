card, door = File.read('input.txt').split("\n").map(&:to_i)

def find_loop_size(card, subject = 7)
  loop_size = 1
  value = 1
  divider = 20201227

  loop {
    value = (value * subject) % divider
    break(loop_size) if value == card
    loop_size += 1
  }
end

print(door.pow(find_loop_size(card), 20201227))
