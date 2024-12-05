use std::{cmp::Ordering, collections::HashMap};

fn is_ordered(update: &[i32], book: &HashMap<(i32, i32), bool>) -> bool {
    for (idx, x) in update.iter().enumerate() {
        for y in &update[idx + 1..] {
            if let Some(false) = book.get(&(*x, *y)) {
                return false;
            }
        }
    }
    true
}

fn cmp(x: i32, y: i32, book: &HashMap<(i32, i32), bool>) -> Ordering {
    let rule = book.get(&(x, y));
    rule.map_or(Ordering::Equal, |v| {
        if *v {
            Ordering::Less
        } else {
            Ordering::Greater
        }
    })
}

fn main() {
    let input = include_str!("input.txt");
    let (rules, updates) = input.split_once("\n\n").expect("expect double newline");
    let rules: Vec<_> = rules
        .lines()
        .map(|rule| {
            let (l, r) = rule.split_once('|').unwrap();
            (l.parse::<i32>().unwrap(), r.parse::<i32>().unwrap())
        })
        .collect();

    let mut book: HashMap<(i32, i32), bool> = HashMap::new();
    for (x, y) in rules.iter() {
        book.insert((*x, *y), true);
        book.insert((*y, *x), false);
    }

    let updates: Vec<Vec<i32>> = updates
        .lines()
        .map(|l| {
            l.split(",")
                .map(|x| x.parse().unwrap())
                .collect::<Vec<i32>>()
        })
        .collect();

    let mut p1 = 0;
    let mut p2 = 0;

    for update in updates {
        if is_ordered(&update, &book) {
            p1 += update[update.len() / 2];
        } else {
            let mut current = update.clone();
            current.sort_by(|x, y| cmp(*x, *y, &book));
            p2 += current[update.len() / 2];
        }
    }

    println!("Part1: {p1}");
    println!("Part2: {p2}");
}
