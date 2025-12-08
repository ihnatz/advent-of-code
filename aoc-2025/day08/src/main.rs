// const INP: &str = include_str!("sample.txt"); const N: usize = 10;
const INP: &str = include_str!("input.txt"); const N: usize = 1_000;

use std::collections::HashMap;

struct UF {
    clusters: Vec<usize>,
}

impl UF {
    fn new(count: usize) -> Self {
        let clusters = (0..count).collect::<Vec<usize>>();
        UF { clusters }
    }

    fn find(&mut self, group: usize) -> usize {
        let parent = self.clusters[group];
        if parent == group {
            return group;
        }
        let actual_parent = self.find(parent);
        self.clusters[group] = actual_parent;
        actual_parent
    }

    fn unite(&mut self, group1: usize, group2: usize) {
        let parent1 = self.find(group1);
        let parent2 = self.find(group2);

        if parent1 == parent2 {
            return;
        }

        self.clusters[parent2] = parent1;
    }
}

#[derive(Debug)]
struct Point {
    x: i64,
    y: i64,
    z: i64,
    idx: usize,
}

impl Point {
    fn from_str(idx: usize, line: &str) -> Self {
        let coords = line
            .split(",")
            .map(|point| point.parse::<i64>().unwrap())
            .collect::<Vec<i64>>();
        let [x, y, z] = coords[..3] else { panic!() };
        Point { idx, x, y, z }
    }

    fn dist(&self, other: &Point) -> i64 {
        (self.x - other.x).pow(2) + (self.y - other.y).pow(2) + (self.z - other.z).pow(2)
    }
}

fn precompute_distances(points: &[Point]) -> Vec<Vec<i64>> {
    let n = points.len();
    let mut d = vec![vec![0; n]; n];

    for i in 0..n {
        for j in i + 1..n {
            let dist = points[i].dist(&points[j]);
            d[i][j] = dist;
            d[j][i] = dist;
        }
    }

    d
}

fn main() {
    let input = INP.to_string();
    let positions = input
        .lines()
        .enumerate()
        .map(|(idx, line)| Point::from_str(idx, line))
        .collect::<Vec<_>>();

    let precomputed = precompute_distances(&positions);
    let mut pairs: Vec<(usize, usize)> = (0..positions.len())
        .flat_map(|i| (i + 1..positions.len()).map(move |j| (i, j)))
        .collect();

    pairs.sort_by_key(|&(i, j)| precomputed[i][j]);

    let mut uf = UF::new(positions.len());
    for (l, r) in &pairs[0..N] {
        uf.unite(*l, *r);
    }

    let mut groups: HashMap<usize, usize> = HashMap::new();
    positions.iter().for_each(|p| {
        groups
            .entry(uf.find(p.idx))
            .and_modify(|val| *val += 1)
            .or_insert(1);
    });

    let mut values: Vec<_> = groups.values().cloned().collect();
    values.sort();
    values.reverse();

    let part1 = values[0..3].iter().product::<usize>();
    println!("Part1: {:?}", part1);

    let mut uf = UF::new(positions.len());
    let mut clusters_remaining = positions.len();
    let mut last_merge: Option<(&Point, &Point)> = None;

    for (i, j) in pairs {
        let pi = uf.find(i);
        let pj = uf.find(j);
        if pi != pj {
            uf.unite(pi, pj);
            clusters_remaining -= 1;
            last_merge = Some((&positions[i], &positions[j]));
            if clusters_remaining == 1 {
                break;
            }
        }
    }

    let (p1, p2) = last_merge.unwrap();
    println!("Part2: {:?}", p1.x * p2.x);
}
