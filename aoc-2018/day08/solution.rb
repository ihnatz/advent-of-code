example = [2, 3, 0, 3, 10, 11, 12, 1, 1, 0, 1, 99, 2, 1, 1, 2]
input = File.read("input.txt").split(" ").map(&:to_i)

def parse_node(list, start = 0, &block)
	pointer = start
	child_nodes = list[pointer]
	metadata_entries = list[pointer + 1]
	pointer += 2
	child_nodes.times do
		pointer = parse_node(list, pointer, &block)
	end

	metadata_entries.times do |i|
		yield list[pointer + i]
	end

	pointer += metadata_entries
	pointer
end

metadatas = []
parse_node(input) { |metadata| metadatas << metadata }
part1 = metadatas.sum


def calculate_node(list, start = 0)
	score = 0
	pointer = start
	child_nodes = list[pointer]
	metadata_entries = list[pointer + 1]
	pointer += 2

	if child_nodes == 0
		score = metadata_entries.times.map { |i| list[pointer + i] }.sum
		return [pointer + metadata_entries, score]
	else
		scores = child_nodes.times.map {
			pointer, prev_score = calculate_node(list, pointer)
			prev_score
		}

		score = metadata_entries.times.map { |i| 
			node_index = list[pointer + i]
			if node_index == 0 
				0
			else 
				scores[node_index - 1] || 0
			end 
		}.sum

		return [pointer + metadata_entries, score]
	end
end

_, part2 = calculate_node(input)

p [part1, part2]
