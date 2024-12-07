// 243 is too low
use std::collections::VecDeque;

fn combine(a: u64, b: u64) -> u64 {
    format!("{}{}", a, b).parse().unwrap()
}

fn is_solvable(need: u64, have: &[u64], with_concat: bool) -> bool {
    let mut q = VecDeque::with_capacity(100);
    q.push_back(('+', 0, have[0]));
    q.push_back(('*', 0, have[0]));

    if with_concat {
        q.push_back(('|', 0, have[0]));
    }
    while !q.is_empty() {
        let (sign, idx, now) = q.pop_back().unwrap();
        if now > need {
            continue;
        }

        let new_now = match sign {
            '+' => now + have[idx + 1],
            '*' => now * have[idx + 1],
            '|' => combine(now, have[idx + 1]),
            _ => unreachable!(),
        };

        if idx + 1 < have.len() - 1 {
            q.push_back(('+', idx + 1, new_now));
            q.push_back(('*', idx + 1, new_now));
            if with_concat {
                q.push_back(('|', idx + 1, new_now));
            }
        }

        if idx + 1 == have.len() - 1 && new_now == need {
            return true;
        }
    }
    false
}

fn main() {
    let input = include_str!("input.txt");
    let pairs: Vec<_> = input
        .lines()
        .map(|line| {
            let (need, have) = line.split_once(": ").expect("combined by :");
            let need: u64 = need.parse().unwrap();
            let have: Vec<u64> = have.split(" ").map(|i| i.parse::<u64>().unwrap()).collect();
            (need, have)
        })
        .collect();

    let p1 = pairs
        .iter()
        .filter(|(need, have)| is_solvable(*need, have, false))
        .map(|(need, _have)| *need)
        .sum::<u64>();
    let p2 = pairs
        .iter()
        .filter(|(need, have)| is_solvable(*need, have, true))
        .map(|(need, _have)| *need)
        .sum::<u64>();
    println!("Part1: {}", p1);
    println!("Part2: {}", p2);
}

#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn test_is_solvable() {
        assert!(is_solvable(190, &[10, 19], false));
        assert!(is_solvable(3267, &[81, 40, 27], false));
        assert!(is_solvable(292, &[11, 6, 16, 20], false));
        assert!(!is_solvable(161011, &[16, 10, 13], false));
        assert!(!is_solvable(156, &[15, 6], false));
    }

    #[test]
    fn test_is_solvable_with_concat() {
        assert!(is_solvable(7290, &[6, 8, 6, 15], true));
        assert!(is_solvable(156, &[15, 6], true));
        assert!(is_solvable(192, &[17, 8, 14], true));
    }
}
