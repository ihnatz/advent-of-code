use regex::Regex;

fn parse_input(input: &str) -> Vec<(i32, i32, i32)> {
    input
        .lines()
        .map(|line| {
            let numbers = extract_numbers(line);
            let [id, positions, _time, start] = numbers[..] else {
                panic!()
            };
            (id, positions, start)
        })
        .collect()
}

fn main() {
    let input = include_str!("input.txt");
    let mut disks = parse_input(input);
    println!("Part1: {}", run(&disks));

    let new_disk = ((disks.len() + 1) as i32, 11, 0);
    disks.push(new_disk);
    println!("Part2: {}", run(&disks));
}

fn run(disks: &[(i32, i32, i32)]) -> i32 {
    let mut n = 0;
    loop {
        n += 1;
        let (id0, pos0, off0) = disks[0];
        let s0 = n * pos0 - off0 - id0;

        let valid = disks
            .iter()
            .all(|(id, positions, start)| (start + s0 + id) % positions == 0);
        if valid {
            return s0;
        }
    }
}

fn extract_numbers(s: &str) -> Vec<i32> {
    let re = Regex::new(r"\d+").unwrap();
    re.find_iter(s)
        .filter_map(|m| m.as_str().parse().ok())
        .collect()
}

#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn test_extract_and_destructure() {
        let s = "Disc #1 has 5 positions; at time=0, it is at position 4.";
        let numbers = extract_numbers(s);
        assert_eq!(numbers, [1, 5, 0, 4]);
    }
}
