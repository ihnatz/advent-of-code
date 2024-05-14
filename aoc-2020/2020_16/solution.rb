require "matrix"

input = File.read("input.txt")
rules, your_ticket, nearby_tickets = input.split("\n\n")

parced_rules = rules
  .split("\n")
  .map { _1.split(": ") }
  .map { |(name, ranges)| [name, ranges.split(" or ")] }
  .map { |(name, description)| {name => description.map { |range| Range.new(*range.split("-").map(&:to_i)) }} }
  .inject(&:merge)

puzzle1 = nearby_tickets
  .split("\n")
  .drop(1)
  .map { _1.split(",") }
  .map { _1.map(&:to_i) }
  .flatten
  .select { |number|
  parced_rules.values.flatten.none? { _1.include?(number) }
}.sum

valid_tickets = nearby_tickets
  .split("\n")
  .drop(1)
  .map { _1.split(",") }
  .map { _1.map(&:to_i) }
  .select { |ticket|
    ticket.all? { |number|
      parced_rules.values.flatten.any? { _1.include?(number) }
    }
  }

valid_mapping = parced_rules.values.map.with_index { |rule, rule_index|
  total_variants = valid_tickets.first.size
  applied = total_variants.times.map { |idx|
    [
      valid_tickets
        .map { _1[idx] }
        .count { |number|
          rule.any? { |range|
            range.include?(number)
          }
        },
      idx
    ]
  }.sort_by { _1.first }

  max_matches = applied.max { _1.first }
  candidates = applied.select { _1.first == max_matches.first }.map { _2 }

  [rule_index, candidates.sort]
}
  .sort_by { _1[1].length }
  .inject({}) { |result, (index, values)| result.merge(index => (values - result.values).first) }
  .sort_by { _1 }
  .map { _1[1] }

departures = parced_rules.keys.select { _1.start_with?("departure ") }.map { parced_rules.keys.index(_1) }

puzzle2 = your_ticket.split("\n").drop(1).first.split(",").map(&:to_i).values_at(*valid_mapping).values_at(*departures).inject(&:*)

p [puzzle1, puzzle2]
