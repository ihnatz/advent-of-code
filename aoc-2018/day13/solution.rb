track = File.read("example.txt").split("\n")

TURNS = [:left, :straight, :right]

Cart = Struct.new(:id, :x, :y, :direction, :turn) do
  attr_accessor :crashed

  def position
    [x, y]
  end
end

def find_carts(track)
  carts = []
  track.each_with_index do |line, y|
    line.chars.each_with_index do |val, x|
      direction = case val
      when '^' then :up
      when '<' then :left
      when '>' then :right
      when 'v' then :down
      else next
      end
      carts << Cart.new(carts.length + 1, x, y, direction, 0)
    end
  end
  carts
end

def simple_turning?(cart, cell)
  ['/', '\\'].include?(cell)
end

def decision_turning?(cart, cell)
  cell == "+"
end

def next_move(cart, track)
  case cart.direction
  when :up     then [cart.x, cart.y - 1]
  when :left   then [cart.x - 1, cart.y]
  when :right  then [cart.x + 1, cart.y]
  when :down   then [cart.x, cart.y + 1]
  end
end

def move(cart, track)
  cart.x, cart.y = next_move(cart, track)

  if simple_turning?(cart, track[cart.y][cart.x])
    cart.direction = {
      ['/', :up] => :right,
      ['/', :down] => :left,
      ['/', :right] => :up,
      ['/', :left] => :down,
      ['\\', :right] => :down,
      ['\\', :left] => :up,
      ['\\', :up] => :left,
      ['\\', :down] => :right,
    }.fetch([track[cart.y][cart.x], cart.direction])
  elsif decision_turning?(cart, track[cart.y][cart.x])
    case TURNS[cart.turn]
    when :left
      cart.direction = {
        down: :right,
        up: :left,
        left: :down,
        right: :up
      }.fetch(cart.direction)
    when :right then
      cart.direction = {
        down: :left,
        up: :right,
        left: :up,
        right: :down
      }.fetch(cart.direction)
    end

    cart.turn = (cart.turn + 1) % TURNS.length
  end
end

carts = find_carts(track)

carts.each do |cart|
  track[cart.y][cart.x] = case cart.direction
  when :left, :right then '-'
  when :up, :down then '|'
  end
end

def colision?(cart1, cart2)
  cart1.id != cart2.id && cart1.position == cart2.position
end

part1 = nil
while carts.count > 1 do
  carts.sort_by!(&:position)

  carts.each do |cart|
    move(cart, track)

    if (crashed = carts.find { colision?(_1, cart) })
      part1 ||= cart.position.join(',')
      crashed.crashed = true
      cart.crashed = true
    end
  end

  carts.reject!(&:crashed)
end

part2 = carts.first.position.join(',')
p [part1, part2]
