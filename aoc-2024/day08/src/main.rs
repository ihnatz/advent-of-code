use std::collections::{HashMap, HashSet};

use itertools::Itertools;

type GridPoint = (usize, usize);
type RawPoint = (i32, i32);

fn clamp(p: RawPoint, width: usize, height: usize) -> Option<GridPoint> {
    let (x, y) = p;
    if x < 0 || y < 0 || !(0..width as i32).contains(&x) || !(0..height as i32).contains(&y) {
        return None;
    }
    Some((x as usize, y as usize))
}

enum CollectionMode {
    Single,
    All,
}

fn main() {
    let input = include_str!("input.txt");

    let width = input.lines().next().map_or(0, |v| v.len());
    let height = input.lines().count();

    let mut antennas = HashMap::new();
    for (y, line) in input.lines().enumerate() {
        for (x, cell) in line.bytes().enumerate() {
            if cell != b'.' {
                antennas.entry(cell).or_insert_with(Vec::new).push((x, y));
            }
        }
    }

    let part1 = process_antinodes(&antennas, width, height, CollectionMode::Single);
    let part2 = process_antinodes(&antennas, width, height, CollectionMode::All);

    println!("Part1: {}", part1.len());
    println!("Part2: {}", part2.len());
}

fn process_antinodes(
    antennas: &HashMap<u8, Vec<GridPoint>>,
    width: usize,
    height: usize,
    mode: CollectionMode,
) -> HashSet<GridPoint> {
    let mut locations = HashSet::new();

    for points in antennas.values() {
        for combination in points.iter().combinations(2) {
            let [a1, a2] = combination[..] else { panic!() };
            match mode {
                CollectionMode::Single => {
                    let (p1, p2) = pair_antinodes(*a1, *a2, 2);
                    [p1, p2].into_iter().for_each(|p| {
                        if let Some(p) = clamp(p, width, height) {
                            locations.insert(p);
                        }
                    });
                }
                CollectionMode::All => {
                    collect_antinodes(*a1, *a2, height, width)
                        .into_iter()
                        .for_each(|p| {
                            locations.insert(p);
                        });
                }
            }
        }
    }
    locations
}

fn pair_antinodes(p1: GridPoint, p2: GridPoint, d: i32) -> (RawPoint, RawPoint) {
    let dy = p1.1 as i32 - p2.1 as i32;
    let dx = p1.0 as i32 - p2.0 as i32;
    let (p1, p2) = if p1.1 < p2.1 { (p1, p2) } else { (p2, p1) };

    (
        (p1.0 as i32 - dx * d, p1.1 as i32 - dy * d),
        (p2.0 as i32 + dx * d, p2.1 as i32 + dy * d),
    )
}

fn collect_antinodes(p1: GridPoint, p2: GridPoint, height: usize, width: usize) -> Vec<GridPoint> {
    (1..)
        .map(|d| {
            let (np1, np2) = pair_antinodes(p1, p2, d);
            [np1, np2]
                .iter()
                .filter_map(|p| clamp(*p, width, height))
                .collect::<Vec<_>>()
        })
        .take_while(|clamped| !clamped.is_empty())
        .flatten()
        .collect()
}

#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn test_pair_antinodes() {
        assert_eq!(pair_antinodes((4, 3), (5, 5), 2), ((6, 7), (3, 1)));
        assert_eq!(pair_antinodes((4, 3), (8, 4), 2), ((12, 5), (0, 2)));

        assert_eq!(pair_antinodes((6, 1), (3, 2), 2), ((0, 3), (9, 0)));
        assert_eq!(pair_antinodes((5, 1), (7, 2), 2), ((9, 3), (3, 0)));
        assert_eq!(pair_antinodes((2, 2), (1, 4), 2), ((0, 6), (3, 0)));
        assert_eq!(pair_antinodes((2, 3), (4, 6), 2), ((6, 9), (0, 0)));
    }

    #[test]
    fn test_antinodes() {
        assert_eq!(
            process_antinodes(
                &HashMap::from([(b'A', vec![(4, 3), (8, 4), (5, 5)])]),
                13,
                13,
                CollectionMode::Single
            ),
            HashSet::from([(12, 5), (0, 2), (6, 7), (3, 1), (2, 6), (11, 3)])
        );
    }

    #[test]
    fn test_collect_antinodes() {
        assert_eq!(
            process_antinodes(
                &HashMap::from([(b'A', vec![(0, 0), (1, 2)])]),
                10,
                10,
                CollectionMode::All
            ),
            HashSet::from([(1, 2), (0, 0), (2, 4), (3, 6), (4, 8)])
        );

        assert_eq!(
            process_antinodes(
                &HashMap::from([(b'A', vec![(0, 0), (3, 1)])]),
                10,
                10,
                CollectionMode::All
            ),
            HashSet::from([(3, 1), (0, 0), (6, 2), (9, 3)])
        );
    }
}
