use std::collections::HashMap;
use std::collections::HashSet;
use std::collections::VecDeque;

fn main() {
    let input = include_str!("input.txt");
    let rsquares = input
        .lines()
        .map(|line| {
            let (c, r) = line.split_once(",").unwrap();
            (r.parse::<i64>().unwrap(), c.parse::<i64>().unwrap())
        })
        .collect::<Vec<_>>();

    println!("Part1: {:?}", max_2_square(&rsquares));
    println!("Part2: {:?}", max_green_square(&rsquares));
}

fn max_2_square(rsquares: &[(i64, i64)]) -> i64 {
    let mut max_square = 0;
    for i in 0..rsquares.len() {
        for j in i + 1..rsquares.len() {
            let (r1, c1) = rsquares[i];
            let (r2, c2) = rsquares[j];
            let square = (1 + (r2 - r1).abs()) * (1 + (c2 - c1).abs());
            if square > max_square {
                max_square = square;
            }
        }
    }
    max_square
}

const DS: [(i64, i64); 4] = [(-1, 0), (0, 1), (1, 0), (0, -1)];

fn max_green_square(rsquares: &[(i64, i64)]) -> i64 {
    let mut rs = rsquares.iter().map(|v| v.0).collect::<Vec<_>>();
    let mut cs = rsquares.iter().map(|v| v.1).collect::<Vec<_>>();
    rs.sort();
    cs.sort();
    rs.dedup();
    cs.dedup();

    let rows = (rs.len() + 1) as i64;
    let cols = (cs.len() + 1) as i64;

    let rs_mapping = rs
        .iter()
        .enumerate()
        .map(|(idx, &val)| (val, idx as i64))
        .collect::<HashMap<i64, i64>>();
    let cs_mapping = cs
        .iter()
        .enumerate()
        .map(|(idx, &val)| (val, idx as i64))
        .collect::<HashMap<i64, i64>>();
    let compressed = rsquares
        .iter()
        .map(|(r, c)| (*rs_mapping.get(r).unwrap(), *cs_mapping.get(c).unwrap()))
        .collect::<Vec<_>>();

    let mut edges = HashSet::new();
    for i in 0..rsquares.len() {
        let left = compressed[i];
        let right = compressed[(i + 1) % compressed.len()];

        for r in std::cmp::min(left.0, right.0)..=std::cmp::max(left.0, right.0) {
            for c in std::cmp::min(left.1, right.1)..=std::cmp::max(left.1, right.1) {
                edges.insert((r, c));
            }
        }
    }

    let mut visited: HashSet<(i64, i64)> = HashSet::new();
    let mut q: VecDeque<(i64, i64)> = VecDeque::new();
    q.push_back((-1, -1));

    while let Some((r, c)) = q.pop_front() {
        if r < -1 || r > rows || c < -1 || c > cols || visited.contains(&(r, c)) {
            continue;
        }
        visited.insert((r, c));

        for (dr, dc) in DS {
            let nr = r + dr;
            let nc = c + dc;
            if !edges.contains(&(nr, nc)) {
                q.push_back((nr, nc));
            }
        }
    }

    let mut inside: HashSet<(i64, i64)> = HashSet::new();
    for r in -1..=rows {
        for c in -1..=cols {
            if !visited.contains(&(r, c)) {
                inside.insert((r, c));
            }
        }
    }

    let mut max_square = 0;

    for i in 0..rsquares.len() {
        for j in i + 1..rsquares.len() {
            let left = compressed[i];
            let right = compressed[j];

            let mut valid = true;
            for r in std::cmp::min(left.0, right.0)..=std::cmp::max(left.0, right.0) {
                for c in std::cmp::min(left.1, right.1)..=std::cmp::max(left.1, right.1) {
                    if !inside.contains(&(r, c)) {
                        valid = false;
                        break;
                    }
                }
                if !valid {
                    break;
                }
            }

            if !valid {
                continue;
            };

            let (r1, c1) = rsquares[i];
            let (r2, c2) = rsquares[j];

            let square = (1 + (r2 - r1).abs()) * (1 + (c2 - c1).abs());

            if square > max_square {
                max_square = square;
            }
        }
    }

    max_square
}
