use std::ops::RangeInclusive;

const DIFF_RANGE: RangeInclusive<i32> = 1..=3;

fn main() {
    let input = include_str!("input.txt");
    let levels: Vec<_> = input
        .lines()
        .map(|line| {
            line.split_ascii_whitespace()
                .map(|i| i.parse().expect(&format!("expect a number, got '{i}'")))
                .collect::<Vec<i32>>()
        })
        .collect();

    let p1 = levels.iter().filter(|l| is_safe(l)).count();
    let p2 = levels.iter().filter(|l| is_partially_safe(l)).count();
    println!("Part1: {p1}");
    println!("Part2: {p2}");
}

fn is_safe(levels: &[i32]) -> bool {
    let direction = (levels[1] - levels[0]) > 0;
    levels.windows(2).all(|pair| {
        let diff = pair[1] - pair[0];
        (diff > 0) == direction && DIFF_RANGE.contains(&diff.abs())
    })
}

fn is_partially_safe(levels: &[i32]) -> bool {
    if is_safe(levels) {
        return true;
    }
    (0..levels.len()).any(|skip| {
        let modified: Vec<_> = levels
            .iter()
            .enumerate()
            .filter(|(i, _)| *i != skip)
            .map(|(_, &v)| v)
            .collect();
        is_safe(&modified)
    })
}

#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn test_is_safe() {
        assert!(is_safe(&vec![7, 6, 4, 2, 1]));
        assert!(!is_safe(&vec![1, 2, 7, 8, 9]));
        assert!(!is_safe(&vec![9, 7, 6, 2, 1]));
        assert!(!is_safe(&vec![1, 3, 2, 4, 5]));
        assert!(!is_safe(&vec![8, 6, 4, 4, 1]));
        assert!(is_safe(&vec![1, 3, 6, 7, 9]));
    }

    #[test]
    fn test_is_partially_safe() {
        assert!(is_partially_safe(&vec![7, 6, 4, 2, 1]));
        assert!(!is_partially_safe(&vec![1, 2, 7, 8, 9]));
        assert!(!is_partially_safe(&vec![9, 7, 6, 2, 1]));
        assert!(is_partially_safe(&vec![1, 3, 2, 4, 5]));
        assert!(is_partially_safe(&vec![8, 6, 4, 4, 1]));
        assert!(is_partially_safe(&vec![1, 3, 6, 7, 9]));
    }
}
