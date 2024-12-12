use std::collections::HashMap;
use std::collections::HashSet;

type GridPoint = (usize, usize);
type RawPoint = (i32, i32);

const DIRECTIONS: [(i32, i32); 4] = [(0, -1), (1, 0), (0, 1), (-1, 0)];

#[inline]
fn clamp(p: RawPoint, grid: &[Vec<u8>]) -> Option<GridPoint> {
    let width = grid[0].len();
    let height = grid.len();
    let (x, y) = p;
    if x < 0 || y < 0 || !(0..width as i32).contains(&x) || !(0..height as i32).contains(&y) {
        return None;
    }
    Some((x as usize, y as usize))
}

fn calculate_area((x0, y0): (usize, usize), grid: &[Vec<u8>]) -> (usize, HashSet<GridPoint>) {
    let mut total = 0;
    let mut q = Vec::new();
    let mut visited = HashSet::new();
    let pcell = grid[y0][x0];

    q.push((x0, y0));

    while let Some(current) = q.pop() {
        if visited.contains(&current) {
            continue;
        }

        visited.insert(current);

        let (x, y) = current;
        let mut around = 4;

        for (dx, dy) in DIRECTIONS {
            if let Some((nx, ny)) = clamp((x as i32 + dx, y as i32 + dy), grid) {
                let ccell = grid[ny][nx];

                if ccell == pcell {
                    around -= 1;
                    q.push((nx, ny));
                }
            }
        }

        total += around
    }

    (total, visited)
}

fn calculate_score((x0, y0): (usize, usize), grid: &[Vec<u8>]) -> (usize, HashSet<GridPoint>) {
    let mut known = HashSet::new();
    let mut sides = HashMap::new();
    let mut q = Vec::new();

    q.push((x0, y0));
    known.insert((x0, y0));
    let target_cell = grid[y0][x0];

    while let Some((x, y)) = q.pop() {
        let mut fences = HashSet::new();
        for (d, (dx, dy)) in DIRECTIONS.iter().enumerate() {
            if let Some((nx, ny)) = clamp((x as i32 + dx, y as i32 + dy), grid) {
                if grid[ny][nx] != target_cell {
                    fences.insert(d);
                } else if !known.contains(&(nx, ny)) {
                    known.insert((nx, ny));
                    q.push((nx, ny));
                }
            } else {
                fences.insert(d);
            }
        }
        sides.insert((x, y), fences);
    }

    let mut seen = HashSet::new();
    let mut count = 0;

    for (cell, edges) in sides.clone().into_iter() {
        for edge in edges.into_iter() {
            if seen.contains(&(cell, edge)) {
                continue;
            }

            seen.insert((cell, edge));
            count += 1;

            let directions = match edge {
                0 => [1, 3],
                2 => [1, 3],
                1 => [0, 2],
                3 => [0, 2],
                _ => panic!(),
            };

            for direction in directions {
                let (dx, dy) = DIRECTIONS[direction];
                let (mut x, mut y) = cell;

                while let Some((nx, ny)) = clamp((x as i32 + dx, y as i32 + dy), grid) {
                    if grid[ny][nx] != grid[y0][x0] {
                        break;
                    }

                    if sides.get(&(nx, ny)).unwrap().contains(&edge) {
                        seen.insert(((nx, ny), edge));
                    } else {
                        break;
                    }

                    (x, y) = (nx, ny);
                }
            }
        }
    }

    (count, known)
}

fn main() {
    let input = include_str!("input.txt");
    let grid: Vec<_> = input
        .trim()
        .lines()
        .map(|line| line.bytes().collect::<Vec<u8>>())
        .collect();

    let mut seen: HashSet<GridPoint> = HashSet::with_capacity(grid.len() * grid[0].len());
    let mut p1: u64 = 0;
    let mut p2: u64 = 0;
    for (y, line) in grid.iter().enumerate() {
        for (x, _) in line.iter().enumerate() {
            if !seen.contains(&(x, y)) {
                let (sides, area) = calculate_score((x, y), &grid);
                let (count, _) = calculate_area((x, y), &grid);
                seen.extend(area.iter());

                p1 += (count * area.len()) as u64;
                p2 += (sides * area.len()) as u64;
            }
        }
    }
    println!("Part1: {p1}");
    println!("Part2: {p2}");
}
