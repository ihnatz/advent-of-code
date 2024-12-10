use std::collections::HashSet;
use std::collections::VecDeque;

type GridPoint = (usize, usize);
type RawPoint = (i32, i32);

const DIRECTIONS: [(i32, i32); 4] = [(0, -1), (1, 0), (0, 1), (-1, 0)];

fn clamp(p: RawPoint, grid: &[Vec<u8>]) -> Option<GridPoint> {
    let width = grid[0].len();
    let height = grid.len();
    let (x, y) = p;
    if x < 0 || y < 0 || !(0..width as i32).contains(&x) || !(0..height as i32).contains(&y) {
        return None;
    }
    Some((x as usize, y as usize))
}

fn main() {
    let input = include_str!("input.txt");
    let grid: Vec<_> = input
        .lines()
        .map(|line| line.bytes().map(|b| b - b'0').collect::<Vec<u8>>())
        .collect();

    let mut starts = HashSet::new();
    for (y, line) in grid.iter().enumerate() {
        for (x, cell) in line.iter().enumerate() {
            if *cell == 0 {
                starts.insert((x, y));
            }
        }
    }

    let (p1, p2) = starts.into_iter().fold((0, 0), |(nines, paths), start| {
        let (dn, dp) = score(start, &grid);
        (nines + dn, paths + dp)
    });

    println!("Part1: {}", p1);
    println!("Part2: {}", p2);
}

fn score((x0, y0): (usize, usize), grid: &[Vec<u8>]) -> (usize, usize) {
    let mut score = HashSet::new();
    let mut total = 0;
    let mut q = VecDeque::new();
    let mut visited = HashSet::new();
    for d in 0..=3 {
        q.push_front((x0, y0, d))
    }

    while let Some(current) = q.pop_back() {
        visited.insert(current);

        let (x, y, d) = current;
        let (dx, dy) = DIRECTIONS[d];

        if let Some((nx, ny)) = clamp((x as i32 + dx, y as i32 + dy), grid) {
            let pcell = grid[y][x];
            let ccell = grid[ny][nx];

            if ccell < pcell || (ccell - pcell) != 1 {
                continue;
            }

            if ccell == 9 {
                score.insert((nx, ny));
                total += 1;
                continue;
            }

            for nd in 0..=3 {
                let np = (nx, ny, nd);
                if nd != (d + 2) % 4 && !visited.contains(&np) {
                    q.push_front(np);
                }
            }
        }
    }

    (score.len(), total)
}
