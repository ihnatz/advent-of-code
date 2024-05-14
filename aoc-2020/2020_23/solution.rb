# RUBY_THREAD_VM_STACK_SIZE=20000000 ruby solution.rb
#
# TODO:
#   use an array which stores pair of values [this_value, next_value]
#   and do not use any links at all

class Node
  attr_accessor :value, :next_node
  def initialize(value, next_node = nil)
    @value = value
    @next_node = next_node
  end
end

class LinkedList
  attr_reader :root, :fast_access

  def initialize(*array_of_values)
    @fast_access = []
    @root = Node.new(array_of_values[0])
    @fast_access[@root.value] = @root

    last = array_of_values.drop(1).inject(@root) do |result, value|
      new_node = Node.new(value)
      @fast_access[new_node.value] = new_node
      result.next_node = new_node
      new_node
    end
    last.next_node = @root
  end

  def enum(from = @root)
    Enumerator.new do |y|
      y << from.value
      current_node = from
      loop {
        current_node = current_node.next_node
        if current_node == from
          break
        end
        y << current_node.value
      }
    end
  end
end

def next_pick(input, current_cup)
  [current_cup.next_node, current_cup.next_node.next_node.next_node]
end

def next_destinataion(current, pick, max)
  min = 1

  new_min = loop {
    break(min) unless pick.include?(min)
    min += 1
  }

  new_max = loop {
    break(max) unless pick.include?(max)
    max -= 1
  }

  i = 1
  destinataion = loop {
    candidate = current - i
    break(candidate) unless pick.include?(candidate)
    i += 1
  }
  destinataion < new_min ? new_max : destinataion
end

def move(input, current_cup)
  start_pick, finish_pick = next_pick(input, current_cup)
  destinataion = next_destinataion(current_cup.value, input.enum(start_pick).take(3), input.fast_access.length - 1)
  destinataion_node = input.fast_access.fetch(destinataion)

  # puts "
  # cups: #{input.enum.to_a}
  # current: #{current_cup.value}
  # pick up: #{input.enum(start_pick).take(3)}
  # destination: #{destinataion}
  # "

  current_cup.next_node = finish_pick.next_node

  save_next_destination_node = destinataion_node.next_node
  destinataion_node.next_node = start_pick
  finish_pick.next_node = save_next_destination_node

  [input, current_cup.next_node]
end


input = File.read("input.txt").gsub(/\s/, '').chars.map(&:to_i)
start = LinkedList.new(*input)

result = 100.times.inject([start, start.root]) { |iteration, index|
  move(iteration.first, iteration.last)
}.first
puzzle_1 = result.enum(result.fast_access[1]).to_a.drop(1).join.to_i

input_2 = input + ((input.max + 1)..1_000_000).to_a

start = LinkedList.new(*input_2)

result = 10_000_000.times.inject([start, start.root]) { |iteration, index|
  move(iteration.first, iteration.last)
}.first

puzzle_2 = result.enum(result.fast_access[1]).take(3).drop(1).inject(:*)

p [puzzle_1, puzzle_2]
