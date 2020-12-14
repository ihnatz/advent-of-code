MASK_PREFIX = "mask = "
MEM_SEPARATOR = " = "
MEM_INFO = "mem[]"

input = File.read("input.txt").split("\n")

def value_with_mask(value, mask)
  padded_value = value.join.rjust(mask.length, "0").chars.map(&:to_i)
  padded_value.zip(mask).map { |(value_bit, mask_bit)|
    case mask_bit
    when "X"
      value_bit
    else
      mask_bit
    end
  }.join.to_i(2)
end

def address_with_mask(address, mask)
  padded_address = address.to_s(2).rjust(mask.length, "0").chars.map(&:to_i)
  padded_address.zip(mask).map { |(value_bit, mask_bit)|
    case mask_bit
    when "0"
      value_bit
    when "1"
      "1"
    else
      "X"
    end
  }.join
end

def address_to_i(address)
  permutations_count = 2**address.chars.count { _1 == "X" }
  permutations_count.times.map { |i|
    replaced = 0
    floating_bits = i.to_s(2).rjust(address.chars.count { _1 == "X" }, "0")
    address.chars.map { |address_bit|
      next(address_bit) unless address_bit == "X"
      new_value = floating_bits[replaced]
      replaced += 1
      new_value
    }
  }.map { _1.join.to_i(2) }
end

puzzle1 = input.inject([{}, []]) { |(mem, mask), line|
  if line.start_with?(MASK_PREFIX)
    mask = line.sub(MASK_PREFIX, "").chars
  else
    cell, value = line.split(MEM_SEPARATOR)
    cell = cell.delete(MEM_INFO).to_i

    value = value.to_i.to_s(2).chars.map(&:to_i)
    mem[cell] = value_with_mask(value, mask)
  end

  [mem, mask]
}.first.values.sum

puzzle2 = input.inject([{}, []]) { |(mem, mask), line|
  if line.start_with?(MASK_PREFIX)
    mask = line.sub(MASK_PREFIX, "").chars
  else
    cell, value = line.split(MEM_SEPARATOR)
    cell = cell.delete(MEM_INFO).to_i

    address_to_i(address_with_mask(cell, mask)).each_with_object(mem) { |address, result|
      result[address] = value.to_i
    }
  end

  [mem, mask]
}.first.values.sum

p [puzzle1, puzzle2]
