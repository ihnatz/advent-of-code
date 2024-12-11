use std::collections::HashMap;

fn gen(stones: &[u64]) -> Vec<u64> {
    stones.into_iter().flat_map(|s| {
        if *s == 0 {
            vec![1]
        } else if (s.ilog10() + 1) % 2 == 0 {
            let d: u32 = (s.ilog10() + 1) as u32 / 2;
            vec![s / 10_u64.pow(d), s % 10_u64.pow(d)]
        } else {
            vec![s * 2024]
        }
    }).collect()
}

fn count_frequencies(values: Vec<u64>) -> HashMap<u64, u64> {
    let mut freq = HashMap::new();
    for value in values {
        *freq.entry(value).or_insert(0) += 1;
    }
    freq
}

fn gen_map(values: &HashMap<u64, u64>) -> HashMap<u64, u64> {
    let mut freq = HashMap::new();
    for (val, count) in values {
        for v in gen(&vec![*val]).iter() {
            *freq.entry(*v).or_insert(0) += count;
        }
    }
    freq
}

fn main() {
    let input = "3028 78 973951 5146801 5 0 23533 857";
    let stones: Vec<_> = input.split_whitespace().map(|v| v.parse::<u64>().unwrap()).collect();
    let start = count_frequencies(stones);

    let p1 = (0..25).fold(start.clone(), |v, _| gen_map(&v)).values().sum::<u64>();
    let p2 = (0..75).fold(start.clone(), |v, _| gen_map(&v)).values().sum::<u64>();

    println!("Part1: {}", p1);
    println!("Part1: {}", p2);
}
