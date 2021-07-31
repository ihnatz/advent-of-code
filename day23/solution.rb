require './core.rb'

def create_core(i)
  code = File.read('input.txt')
  core = Core.new(code, [i])
  core.awaiting_in = false
  core.run
  core
end

def run(part1 = false, part2 = false)
  prev_nat = nil
  nat_inbox = []
  inbox = {}
  cores = (0..49).map { |i| create_core(i) }
  (0..49).each { |i| inbox[i] = [] }

  tick = 0
  loop do
    if inbox.values.all?(&:empty?) && part2
      if !nat_inbox.empty?
        if nat_inbox == prev_nat
          puts "*" * 80
          puts prev_nat[1]
          puts "*" * 80
          return
        end
        prev_nat = nat_inbox.dup
      end
      inbox[0] << nat_inbox
    end

    tick += 1

    inbox.entries.each { |(core_idx, messages)|
      next if !nat_inbox.empty? && inbox.values.all?(&:empty?)

      core = cores[core_idx]

      core.input = messages.empty? ? [-1] : messages.shift
      core.awaiting_in = false

      loop {
        core.run
        break if core.awaiting_in || core.halted
      }

      if !core.output.empty?
        core.output.each_slice(3) do |(y, x, to)|
          if part1 && to == 255
            puts "*" * 80
            puts y
            puts "*" * 80
            return
          end

          if to == 255
            nat_inbox = [x, y]
          else
            inbox[to] << [x, y]
          end
        end

        core.output.clear
      end
    }
  end
end

run(true, false)
run(false, true)

