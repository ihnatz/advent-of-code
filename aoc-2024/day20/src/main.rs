use std::collections::HashSet;
use std::collections::VecDeque;

type Point = (i32, i32);
const DIRECTIONS: [Point; 4] = [(0, -1), (1, 0), (0, 1), (-1, 0)];

fn path(s: Point, f: Point, walls: &HashSet<Point>) -> Vec<Point> {
    let mut q = VecDeque::new();
    let mut seen = HashSet::new();
    q.push_back((s, vec![s]));

    while let Some((point, path)) = q.pop_front() {
        let state = (point, path.len());
        if seen.contains(&state) {
            continue;
        }
        seen.insert(state);

        if point == f {
            return path;
        }
        let (x, y) = point;
        for (dx, dy) in DIRECTIONS {
            let new_point = (x + dx, y + dy);
            if !walls.contains(&new_point) && !path.contains(&new_point) {
                let mut new_path = path.clone();
                new_path.push(new_point);
                q.push_back((new_point, new_path));
            }
        }
    }

    unreachable!();
}

fn main() {
    let input = include_str!("input.txt");
    let limit = 100;

    let mut walls = HashSet::new();
    let mut start = (0, 0);
    let mut finish = (0, 0);

    for (y, line) in input.trim().lines().enumerate() {
        for (x, cell) in line.bytes().enumerate() {
            let x = x as i32;
            let y = y as i32;
            match cell {
                b'#' => {
                    walls.insert((x, y));
                }
                b'S' => {
                    start = (x, y);
                }
                b'E' => {
                    finish = (x, y);
                }
                b'.' => (),
                _ => unreachable!(),
            }
        }
    }

    let shortest = path(start, finish, &walls);
    let n = shortest.len();
    let (mut p1, mut p2) = (0, 0);

    for idx in 0..n {
        let (x1, y1) = shortest[idx];
        for jump_point in idx + 1..n {
            let (x2, y2) = shortest[jump_point];
            let d = ((x1 - x2).abs() + (y1 - y2).abs()) as usize;
            let savings = jump_point - idx - d;

            if savings >= limit {
                if d <= 20 {
                    p2 += 1;
                }
                if d <= 2 {
                    p1 += 1;
                }
            }
        }
    }

    println!("Part1: {:?}", p1);
    println!("Part2: {:?}", p2);
}
