use std::{collections::HashMap, iter::zip};

fn main() {
    let input = include_str!("input.txt");
    let mut m1 = Vec::new();
    let mut m2 = Vec::new();

    for line in input.lines() {
        let parts: Vec<_> = line.split_ascii_whitespace().map(|s| s.to_string()).collect();
        let [l, r] = parts.as_slice() else {panic!()};
        m1.push(l.parse::<i32>().unwrap());
        m2.push(r.parse::<i32>().unwrap());
    }

    m1.sort();
    m2.sort();

    let p1: i32 = zip(m1.iter(), m2.iter()).map(|(l, r)| (r - l).abs()).sum();
    println!("Part1: {p1}");

    let mut f = HashMap::new();
    for i in m2.iter() {
        *f.entry(i).or_insert(0) += 1;
    };

    let p2: i32 = m1.iter().map(|v| f.get(v).unwrap_or(&0) * v).sum();
    println!("Part2: {p2}");
}
