fn main() {
    let input = include_str!("input.txt");
    let lines = input
        .lines()
        .map(|line| {
            line.chars()
                .map(|c| c.to_digit(10).unwrap())
                .collect::<Vec<_>>()
        })
        .collect::<Vec<_>>();

    let mut part1 = 0;
    let mut part2 = 0;

    for line in lines {
        part1 += run(&line, 0, 0, 2);
        part2 += run(&line, 0, 0, 12);
    }
    println!("Part1: {}", part1);
    println!("Part2: {}", part2);
}

fn run(line: &[u32], idx: usize, current: u64, expected: usize) -> u64 {
    if expected == 0 {
        return current;
    }
    let mut max_idx = idx;
    for i in idx..(line.len() - expected + 1) {
        if line[i] > line[max_idx] {
            max_idx = i;
        }
    }
    let num = line[max_idx] as u64;
    run(line, max_idx + 1, current * 10 + num, expected - 1)
}
