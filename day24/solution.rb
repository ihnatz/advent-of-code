require 'logger'
DEBUG = false
# input = File.read("sample.txt")
input = File.read("input.txt")

Group = Struct.new(:id, :side, :units, :hp, :weak, :immune, :attack, :type, :initiative) do
  def effective_power() = units * attack
  def nice_name() = self.side == :immune_system ? "Immune system" : "Infection"

  def can_attack(group)
    default_damage = effective_power
    return 0 if group.immune.include?(self.type)
    return default_damage * 2 if group.weak.include?(self.type)
    default_damage
  end
end

def parse_line(t, str, current)
  units = str.match(/(\d+) units/)[1].to_i
  hp = str.match(/(\d+) hit points/)[1].to_i
  weak = str.match(/weak to ([A-Za-z,\s]+)[\);]*/).to_a[1].to_s.split(", ")
  immune = str.match(/immune to ([A-Za-z,\s]+)[\);]*/).to_a[1].to_s.split(", ")
  attack = str.match(/attack that does (\d+) /)[1].to_i
  type = str.match(/attack that does \d+ (\w+) damage/)[1]
  initiative = str.match(/at initiative (\d+)/)[1].to_i

  Group.new(t, current, units, hp, weak, immune, attack, type, initiative)
end

groups = []
current = :immune_system
t = 1

input.chomp.split("\n").map(&:chomp).drop(1).each do |line|
  if line.start_with?("Infection")
    current = :infection
    t = 1
    next
  end

  unless line.empty?
    groups << parse_line(t, line, current)
    t += 1
  end
end

def fight(groups)
  round = 1
  logger = Logger.new(DEBUG ? STDOUT : '/dev/null')

  state = groups.map(&:units)

  loop do
    logger.info "Round #{round}"
    logger.info ""
    round += 1

    logger.info "Immune System:"
    immune_system_groups = groups.select { _1.side == :immune_system }
    immune_system_groups.each do |group|
      logger.info "Group #{group.id} contains #{group.units} units"
    end

    logger.info "Infection:"
    infection_groups = groups.select { _1.side == :infection }
    infection_groups.each do |group|
      logger.info "Group #{group.id} contains #{group.units} units"
    end

    logger.info ""

    break if groups.map(&:side).uniq.count == 1

    groups.sort_by! { [-_1.effective_power, -_1.initiative] }
    rounds = []
    immune_system_defending = immune_system_groups.dup
    infection_groups_defending = infection_groups.dup

    groups.each do |group|
      enemies = group.side == :infection ? immune_system_defending : infection_groups_defending
      enemies.each do |attacked_group|
        damage = group.can_attack(attacked_group)
        logger.info "#{group.nice_name} group #{group.id} would deal defending group #{attacked_group.id} #{damage} damage"
      end

      choosen = enemies.max_by { [group.can_attack(_1), _1.effective_power, _1.initiative] }

      if choosen && group.can_attack(choosen) > 0
        enemies.delete(choosen)
        rounds << [group, choosen]
      end
    end

    logger.info ""

    rounds.sort_by! { -_1.first.initiative }
    rounds.each do |(attacker, defender)|
      next if attacker.units <= 0
      damage = attacker.can_attack(defender)
      units_to_be_killed = damage / defender.hp
      units_to_be_killed = [units_to_be_killed, defender.units].min
      defender.units -= units_to_be_killed

      logger.info "#{attacker.nice_name} group #{attacker.id} attacks defending group #{defender.id}, killing #{units_to_be_killed} units"
    end

    groups.reject! { _1.units <= 0 }
    logger.info ""
    logger.info ""

    return [:tie, groups.sum(&:units)] if state == groups.map(&:units)
    state = groups.map(&:units)
  end

  [groups.first.side, groups.sum(&:units)]
end

part1 = fight(groups.map(&:dup)).last

#---------------------------------------------

expected = (0..10_000).bsearch { |boost|
  candidates = groups.map(&:dup)
  candidates.select { _1.side == :immune_system }.each { _1.attack += boost }

  fight(candidates)[0] == :immune_system
}

candidates = groups.map(&:dup)
candidates.select { _1.side == :immune_system }.each { _1.attack += expected }

part2 = fight(candidates).last

#---------------------------------------------

p [part1, part2]
