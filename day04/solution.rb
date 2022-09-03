require 'date'

events = File.read("input.txt").split("\n")

def parse_date(d)
  DateTime.parse(d.match(/\[.+\]/)[0].slice(1..-2))
end

current = nil
schedule = events.sort_by { |d| parse_date(d) }.map { |desc|
  date = parse_date(desc)
  event = case
  when desc.include?("falls asleep") then :asleep
  when desc.include?("wakes up") then :wakeup
  else
    current = desc.match(/ \#(\d+) /)[1].to_i
    date = DateTime.new(date.year, date.month, date.day, 0, 0, 0) + 1 if date.hour >= 23
    :start
  end

  [current, date, event]
}

guards = {}
schedule.group_by { |current, date, _| [current, date.to_date] }.each do |(guard, day), events|
  guards[guard] ||= {}
  guards[guard][day] = []
  events.drop(1).each_slice(2).each do |(st, fn)|
    (st[1].minute...fn[1].minute).to_a.each { |min| guards[guard][day] << min }
  end
end

sleepy_guard = guards.map { |guard, events|
  [guard, events.values.flatten.count]
}.sort_by(&:last).last.first
sleepest_minute = guards[sleepy_guard].values.inject(&:+).tally.sort_by(&:last).last.first
part1 = sleepest_minute * sleepy_guard

common_minutes = guards.map { |guard, events|
  [guard, events.values.flatten.tally.sort_by(&:last).last || [0, 0]]
}.sort_by { -_1.last.last }.first
part2 = common_minutes[0] * common_minutes[1][0]

p [part1, part2]
