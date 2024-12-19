use std::collections::HashSet;

fn solve_dp(colors: &HashSet<&str>, pattern: &str) -> usize {
    let maxlen = colors.iter().map(|s| s.len()).max().unwrap();
    let mut dp: Vec<usize> = vec![0; pattern.len()];
    dp.insert(0, 1);

    for start in 0..pattern.len() {
        for i in 1..=maxlen {
            if start + i > pattern.len() {
                continue;
            }
            if colors.contains(&pattern[start..start + i]) {
                dp[start + i] += dp[start];
            }
        }
    }

    dp[pattern.len()]
}



fn main() {
    let input = include_str!("input.txt").trim();
    let (colors, patterns) = input.split_once("\n\n").unwrap();
    let colors: HashSet<_> = colors.split(", ").collect();
    let patterns: Vec<_> = patterns.lines().collect();

    let mut p1 = 0;
    let mut p2 = 0;

    for pattern in &patterns {
        let count = solve_dp(&colors, pattern);
        p1 += count.min(1);
        p2 += count;
    }

    println!("Part1: {:?}", p1);
    println!("Part2: {:?}", p2);
}
