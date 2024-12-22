use std::collections::HashMap;

fn next(secret: i64) -> i64 {
    let mut secret = (secret ^ secret << 6) % 16777216;
    secret = (secret ^ secret >> 5) % 16777216;
    (secret ^ secret << 11) % 16777216
}

fn run(secret: i64, rounds: usize) -> i64 {
    let mut current = secret;
    for _ in 0..rounds {
        current = next(current);
    }
    current
}

fn run_with_sequnce(secret: i64, rounds: usize) -> HashMap<Vec<i64>, i64> {
    let mut known: HashMap<Vec<i64>, i64> = HashMap::new();
    let mut current = secret;
    let mut last_prices = vec![current % 10];
    let mut changes = Vec::with_capacity(4);

    for _ in 0..rounds {
        current = next(current);
        let price = current % 10;
        let delta = price - *last_prices.last().unwrap();

        changes.push(delta);
        if changes.len() > 4 {
            changes.remove(0);
        }

        if changes.len() == 4 {
            let seq = changes.clone();
            known.entry(seq).or_insert(price);
        }

        last_prices.push(price);
        if last_prices.len() > 2 {
            last_prices.remove(0);
        }
    }

    known
}

fn main() {
    let input = include_str!("input.txt").trim();
    let numbers = input
        .lines()
        .map(|v| v.parse::<i64>().unwrap())
        .collect::<Vec<i64>>();

    let p1 = numbers.iter().map(|v| run(*v, 2000)).sum::<i64>();
    println!("Part1: {:?}", p1);

    let mut known: HashMap<Vec<i64>, i64> = HashMap::new();
    for &number in &numbers {
        let sequences = run_with_sequnce(number, 2000);
        for (seq, price) in sequences {
            *known.entry(seq).or_insert(0) += price;
        }
    }

    let p2 = known.values().max().unwrap();
    println!("Part2: {}", p2);
}
