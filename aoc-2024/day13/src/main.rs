const OFFSET: u64 = 10000000000000;
const LIMIT: u64 = 100;
const COST_A: u64 = 3;
const COST_B: u64 = 1;

fn solve_math(case: ((u64, u64), (u64, u64), (u64, u64))) -> (u64, u64) {
    let (ax, ay) = case.0;
    let (bx, by) = case.1;
    let (ex, ey) = case.2;

    let (ax, ay, bx, by) = (ax as i128, ay as i128, bx as i128, by as i128);
    let (ex, ey) = (ex as i128, ey as i128);

    let numerator = ey * ax - ay * ex;
    let denominator = by * ax - ay * bx;

    if denominator == 0 || numerator % denominator != 0 {
        return (0, 0);
    }

    let p2 = numerator / denominator;

    let numerator_p1 = ex - bx * p2;
    if numerator_p1 % ax != 0 {
        return (0, 0);
    }

    let p1 = numerator_p1 / ax;

    if p1 < 0 || p2 < 0 {
        (0, 0)
    } else {
        (p1 as u64, p2 as u64)
    }
}

fn score(pa: u64, pb: u64) -> u64 {
    pb * COST_B + pa * COST_A
}

fn main() {
    let input = include_str!("input.txt");
    let cases: Vec<_> = input
        .trim()
        .split("\n\n")
        .map(|case| {
            let pairs = case
                .lines()
                .collect::<Vec<_>>()
                .into_iter()
                .map(|line| {
                    let (_, value) = line.split_once(": ").unwrap();
                    let (x, y) = value.split_once(", ").unwrap();
                    let x = x[2..].parse::<u64>().unwrap();
                    let y = y[2..].parse::<u64>().unwrap();
                    (x, y)
                })
                .collect::<Vec<_>>();
            let [l, r, exp] = pairs[..] else {
                panic!();
            };
            (l, r, exp)
        })
        .collect();

    let mut p1 = 0;
    let mut p2 = 0;
    for case in cases {
        let (buta, butb, exp) = case;

        let (pa, pb) = solve_math((buta, butb, exp));
        if pb < LIMIT && pa < LIMIT {
            p1 += score(pa, pb);
        }

        let (pa, pb) = solve_math((buta, butb, (exp.0 + OFFSET, exp.1 + OFFSET)));
        p2 += score(pa, pb);
    }

    println!("Part1: {p1}");
    println!("Part2: {p2}");
}
