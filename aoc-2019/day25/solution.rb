require_relative './core.rb'


REVERSE = {
  "north" => "south",
  "south" => "north",
  "west"  => "east",
  "east"  => "west"
}


def to_code(input)
  (input + "\n").chars.map(&:ord)
end

def parse_output(output, verbose = true)
  directions, items = nil, nil
  text = output.map(&:chr).join.split("\n").reject(&:empty?)
  title = text[0].match(/== (.+) ==/)[1]
  description = text[1]

  puts([title, description]) if verbose

  if (offset = text.index("Doors here lead:"))
    directions = text.slice(offset + 1...).take_while { |x| x.start_with?("- ") }.map  { |dir|  dir.slice(2..) }.reject(&:empty?)
    puts ["Directions: ", directions.join(", ")] if verbose
  end

  if (offset = text.index("Items here:"))
    items = text.slice(offset + 1...).take_while { |x| x.start_with?("- ") }.map  { |dir|  dir.slice(2..) }.reject(&:empty?)
    puts ["Items: ", items.join(", ")] if verbose
  end

  puts "------------------------------" if verbose
  [title, directions, items]
end

State = Struct.new(:room, :items)

require 'set'
ALL_ITEMS = Set.new
$security_path = nil

def generate_game
  code = File.read('input.txt')
  core = Core.new(code, [])

  Enumerator.new do |y|
    loop do
      break if core.halted
      result = core.run

      if core.awaiting_in
        begin
          y << core
        rescue => e
          print(core.output.reverse.map(&:chr).join)
          require 'pry'; binding.pry
          break
        end

        core.output.clear
        core.awaiting_in = false
      end
    end
  end
end


def traverse(game, map, items, path = [], prev_room: nil)
  core = game.next
  current_title, current_directions, current_items = parse_output(core.output.reverse, false)

  $security_path = path if current_title == "Security Checkpoint"

  if !map[current_title]
    map[current_title] = {}
    current_directions.each { |dir| map[current_title][dir] = nil }
  end

  if prev_room
    last_dir = path.last
    map[prev_room][last_dir] = current_title
    map[current_title][REVERSE.fetch(last_dir)] = prev_room
  else
    map[:root] = current_title
  end

  if current_items
    current_items.each do |item|
      next if item == "infinite loop"
      next if item == "molten lava"
      next if item == "photons"
      next if item == "giant electromagnet"
      next if item == "escape pod"

      core.input = to_code("take #{item}")
      game.next
      items << item
      ALL_ITEMS << item
    end
  end

  current_directions.each do |dir|
    next if map[current_title][dir]
    core.input = to_code(dir)
    traverse(game, map, items, path + [dir], prev_room: current_title)
    core.input = to_code(REVERSE.fetch(dir))
    game.next
  end

  core
end

def at_security_gate
  game = generate_game
  core = traverse(game, {}, [])
  $security_path.each do |dir|
    core.input = to_code(dir)
    game.next
  end
  core
end

core = Marshal.dump(at_security_gate)

(0..ALL_ITEMS.length).map { |i|
  ALL_ITEMS.to_a.combination(i).to_a
}.flatten(1).reject(&:empty?).each do |combination|
  new_core = Marshal.load(core)

  (ALL_ITEMS - combination).each do |to_drop|
    new_core.input = to_code("drop #{to_drop}")
    new_core.awaiting_in = false
    while !new_core.awaiting_in do new_core.run end
  end

  new_core.output.clear
  new_core.input = to_code("inv")
  new_core.awaiting_in = false
  while !new_core.awaiting_in do new_core.run end
  current = new_core.output.reverse.map(&:chr).join.split("\n").select { |x| x.start_with?("- ") }.join(" ")
  new_core.output.clear

  new_core.input = to_code("north")
  new_core.awaiting_in = false
  while !new_core.awaiting_in && !new_core.halted do new_core.run end

  if !new_core.output.reverse.map(&:chr).join.include?("Alert")
    p new_core.output.reverse.map(&:chr).join.match(/\d+/)[0].to_i
    break
  end
end
