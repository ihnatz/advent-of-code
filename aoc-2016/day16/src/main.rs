#![allow(dead_code)]

const INPUT: &str = "10010000000110000";
const LEN1: usize = 272;
const LEN2: usize = 35651584;

const T: bool = true;
const F: bool = false;

fn step(input: &[bool]) -> Vec<bool> {
    let mut result = Vec::with_capacity(input.len() * 2 + 1);
    result.extend_from_slice(input);
    result.push(F);
    result.extend(input.iter().rev().map(|&b| !b));
    result
}

fn populate(input: &[bool], expected: usize) -> Vec<bool> {
    let mut current = input.to_vec();
    while current.len() < expected {
        current = step(current.as_slice())
    }
    current.truncate(expected);
    current
}

fn checksum(input: &[bool]) -> Vec<bool> {
    let mut current = input.to_vec();
    while current.len() % 2 == 0 {
        current = current
            .chunks(2)
            .map(|chunk| chunk[0] == chunk[1])
            .collect();
    }
    current.to_vec()
}

fn str_to_vec(input: &str) -> Vec<bool> {
    input.bytes().map(|v| v == b'1').collect()
}

fn run(input: &[bool], expected: usize) -> String {
    let current = populate(input, expected);
    checksum(current.as_slice())
        .into_iter()
        .map(|v| if v { "1" } else { "0" })
        .collect()
}

fn main() {
    println!("Part1: {}", run(str_to_vec(INPUT).as_slice(), LEN1));
    println!("Part2: {}", run(str_to_vec(INPUT).as_slice(), LEN2));
}

#[cfg(test)]
mod tests {
    use std::vec;

    use super::*;

    #[test]
    fn test_step() {
        assert_eq!(step(&[T]), vec![T, F, F]);
        assert_eq!(step(&[F]), vec![F, F, T]);
        assert_eq!(
            step(&[T, T, T, T, T]),
            vec![T, T, T, T, T, F, F, F, F, F, F]
        );
    }

    #[test]
    fn test_populate() {
        assert_eq!(
            populate(&[T, F, F, F, F], 20),
            vec![T, F, F, F, F, F, T, T, T, T, F, F, T, F, F, F, F, T, T, T],
        );
    }

    #[test]
    fn test_checksum() {
        assert_eq!(
            checksum(&[T, T, F, F, T, F, T, T, F, T, F, F,]),
            vec![T, F, F]
        );
    }

    #[test]
    fn test_run() {
        assert_eq!(run(&[T, F, F, F, F], 20), "01100");
    }
}
