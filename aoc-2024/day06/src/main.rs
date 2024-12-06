use std::collections::HashSet;

type Point = (usize, usize);
type Delta = (i32, i32);
type Grid = HashSet<Point>;

const DIRECTIONS: [Delta; 4] = [(0, -1), (1, 0), (0, 1), (-1, 0)];

fn step(
    (x, y): Point,
    dir: usize,
    obstructions: &Grid,
    height: i32,
    width: i32,
) -> Option<(Point, usize)> {
    let (x, y) = (x as i32, y as i32);
    let (dx, dy) = DIRECTIONS[dir];

    let (nx, ny) = (x + dx, y + dy);
    if nx < 0 || ny < 0 || nx >= width || ny >= height {
        return None;
    }

    let next = (nx as usize, ny as usize);
    if obstructions.contains(&next) {
        Some(((x as usize, y as usize), (dir + 1) % DIRECTIONS.len()))
    } else {
        Some((next, dir))
    }
}

fn is_loop(now: Point, obstructions: &Grid, height: i32, width: i32) -> bool {
    let mut slow = (now.0, now.1, 0);
    let mut fast = slow;

    loop {
        match step((slow.0, slow.1), slow.2, obstructions, height, width) {
            Some(((nx, ny), nd)) => slow = (nx, ny, nd),
            None => return false,
        }

        for _ in 0..2 {
            match step((fast.0, fast.1), fast.2, obstructions, height, width) {
                Some(((nx, ny), nd)) => fast = (nx, ny, nd),
                None => return false,
            }
        }

        if slow == fast {
            return true;
        }
    }
}

fn main() {
    let input = include_str!("input.txt").trim();
    let mut start = (0, 0);
    let mut obstructions = Grid::new();

    let height = input.lines().count() as i32;
    let width = input.lines().collect::<Vec<_>>()[0].len() as i32;

    for (y, row) in input.lines().enumerate() {
        for (x, cell) in row.bytes().enumerate() {
            match cell {
                b'#' => {
                    obstructions.insert((x, y));
                }
                b'^' => {
                    start = (x, y);
                }
                _ => (),
            }
        }
    }

    let mut d = 0;
    let (mut x, mut y) = start;
    let mut visited = Grid::from([start]);

    while let Some(((nx, ny), nd)) = step((x, y), d, &obstructions, height, width) {
        visited.insert((nx, ny));
        (x, y, d) = (nx, ny, nd);
    }
    println!("Part1: {}", visited.len());

    let mut loops = 0;
    for &point in visited.iter() {
        obstructions.insert(point);
        if is_loop(start, &obstructions, height, width) {
            loops += 1;
        }
        obstructions.remove(&point);
    }
    println!("Part2: {}", loops);
}
