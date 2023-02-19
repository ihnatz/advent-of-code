# input = '^ENWWW(NEEE|SSE(EE|N))$'
# input = "^ENNWSWW(NEWS|)SSSEEN(WNSE|)EE(SWEN|)NNN$"
# input = '^ESSWWN(E|NNENN(EESS(WNSE|)SSS|WWWSSSSE(SW|NNNE)))$'
# input = '^WSSEESWWWNW(S|NENNEEEENN(ESSSSW(NWSW|SSEN)|WSWWN(E|WWS(E|SS))))$'
input = File.read("input.txt").strip
chars = input[1..-2].chars

def traverse(chars)
  total = []
  collected = []
  idx = 0

  while idx < chars.length
    val = chars[idx]
    if "NEWS".chars.include?(val)
      collected << val
    elsif val == "("
      start = idx
      finish = branch(chars, start)
      branch = chars.slice(start + 1..finish)
      collected << traverse(branch)
      idx = finish
    elsif val == "|"
      total << collected
      collected = []
    elsif val == ")"

    end
    idx += 1
  end
  total << collected

  total
end

def branch(chars, idx)
  depth = 1

  while depth != 0
    idx += 1
    val = chars[idx]
    depth += 1 if val == "("
    depth -= 1 if val == ")"
  end

  idx - 1
end

def travel(path, distances, x = 0, y = 0, current = 0)
  path.each do |val|
    if val.is_a?(String)
      case val
      when "N" then y -= 1
      when "S" then y += 1
      when "E" then x += 1
      when "W" then x -= 1
      end
      current += 1
      distances[[x, y]] = [distances[[x, y]], current].compact.min
    else
      val.each do |candidate|
        travel(candidate, distances, x, y, current)
      end
    end
  end
  distances
end

ways = traverse(chars)
distances = {}
map = travel(ways[0], distances)

part1 = map.values.max
part2 = map.values.select { _1 >= 1_000 }.count
p [part1, part2]

def unwrap(ways)
  candidates = [[]]
  ways.each do |val|
    if val.is_a?(String)
      candidates.each { _1 << val }
    else
      next_level = []
      val.each do |way|
        candidates.each do |candidate|
          unwrap(way).each do |subway|
            next_level << (candidate + subway)
          end
        end
      end
      candidates = next_level
    end
  end
  candidates
end
