use std::collections::{HashSet, VecDeque};

const DIRECTIONS: [(i32, i32); 8] = [
    (0, -1),
    (1, -1),
    (1, 0),
    (1, 1),
    (0, 1),
    (-1, 1),
    (-1, 0),
    (-1, -1),
];
const WORD: &[u8; 4] = b"XMAS";

const X_DIRECTIONS: [(i32, i32); 4] = [(-1, -1), (1, -1), (1, 1), (-1, 1)];
const X_WORD: &[u8; 4] = b"MSSM";

fn next_char(c: u8) -> Option<u8> {
    WORD.iter()
        .position(|&x| x == c)?
        .checked_add(1)
        .and_then(|i| WORD.get(i).copied())
}

fn is_in_bounds(x: i32, y: i32, width: i32, height: i32) -> bool {
    x >= 0 && y >= 0 && x < width && y < height
}

fn get_x_mas(x0: usize, y0: usize, grid: &[Vec<u8>], expected: &HashSet<Vec<u8>>) -> u32 {
    let width = grid[0].len() as i32;
    let height = grid.len() as i32;

    let cross: Vec<_> = X_DIRECTIONS
        .iter()
        .map(|(dx, dy)| (x0 as i32 + dx, y0 as i32 + dy))
        .filter(|&(nx, ny)| is_in_bounds(nx, ny, width, height))
        .map(|(nx, ny)| grid[ny as usize][nx as usize])
        .collect();

    if cross.len() == 4 && expected.contains(&cross) {
        1
    } else {
        0
    }
}

fn fill(x0: usize, y0: usize, grid: &[Vec<u8>]) -> u32 {
    let c0 = grid[y0][x0];
    let width = grid[0].len() as i32;
    let height = grid.len() as i32;

    let mut found = 0;
    let mut visited = HashSet::new();
    let mut q = VecDeque::new();
    for dir in DIRECTIONS {
        q.push_back((c0, x0, y0, dir));
    }

    while !q.is_empty() {
        let cur = q.pop_front().unwrap();
        if visited.contains(&cur) {
            continue;
        }
        visited.insert(cur);
        let (c, x, y, dir) = cur;
        let nc = next_char(c);

        if nc.is_none() {
            found += 1;
            continue;
        } else {
            let nc = nc.unwrap();
            let (dx, dy) = dir;
            let (nx, ny) = (x as i32 + dx, y as i32 + dy);
            if is_in_bounds(nx, ny, width, height) && grid[ny as usize][nx as usize] == nc {
                q.push_back((nc, nx as usize, ny as usize, dir));
            }
        }
    }
    found
}

fn main() {
    let input = include_str!("input.txt");
    let grid: Vec<Vec<u8>> = input.lines().map(|line| line.bytes().collect()).collect();

    let mut expected = HashSet::new();
    let mut pattern = X_WORD.to_vec();
    for i in 0..4 {
        pattern.rotate_right(i);
        expected.insert(pattern.clone());
    }

    let mut p1: u32 = 0;
    let mut p2: u32 = 0;

    for (y, row) in grid.iter().enumerate() {
        for (x, &cell) in row.iter().enumerate() {
            match cell {
                b'X' => p1 += fill(x, y, &grid),
                b'A' => p2 += get_x_mas(x, y, &grid, &expected),
                _ => (),
            }
        }
    }
    println!("Part1: {p1}");
    println!("Part2: {p2}");
}
