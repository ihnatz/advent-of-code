use itertools::Itertools;
use std::collections::{HashSet, VecDeque};

type Point = (usize, usize);
const DIRECTIONS: [(i32, i32); 4] = [(0, -1), (1, 0), (0, 1), (-1, 0)];

fn find_neighbors(n: usize, start: Point, grid: &Vec<Vec<char>>) -> Vec<i32> {
    let mut dst = vec![-1; n];
    let mut q = VecDeque::new();
    let mut visited = HashSet::new();

    dst[(grid[start.1][start.0] as u8 - '0' as u8) as usize] = 0;
    q.push_back((start, 0));
    while !q.is_empty() {
        let (cur, steps) = q.pop_front().unwrap();
        if visited.contains(&cur) {
            continue;
        }
        visited.insert(cur);

        let (x, y) = cur;
        for (dx, dy) in DIRECTIONS {
            let nx = x as i32 + dx;
            let ny = y as i32 + dy;
            if nx >= 0 && ny >= 0 && (ny as usize) < grid.len() && (nx as usize) < grid[0].len() {
                let nx = nx as usize;
                let ny = ny as usize;
                let cell = grid[ny][nx];
                if cell == '.' || cell.is_numeric() {
                    q.push_back(((nx, ny), steps + 1));
                }

                if cell.is_numeric() {
                    let val = cell as u8 - '0' as u8;
                    if dst[val as usize] == -1 || steps + 1 < dst[val as usize] {
                        dst[val as usize] = steps + 1;
                    }
                }
            }
        }
    }

    dst
}

fn way_len(way: Vec<usize>, matrix: &Vec<Vec<i32>>) -> i32 {
    let mut total = 0;
    let mut i = 0;
    for dst in way {
        if matrix[i][dst as usize] == -1 {
            return -1;
        } else {
            total += matrix[i][dst as usize];
        }
        i = dst as usize;
    }
    total
}

fn way_len_with_return(way: Vec<usize>, matrix: &Vec<Vec<i32>>) -> i32 {
    let way_back = matrix[*way.last().unwrap()][0];

    if way_back == -1 {
        return -1;
    }

    let mut total = 0;
    let mut i = 0;
    for dst in way {
        if matrix[i][dst as usize] == -1 {
            return -1;
        } else {
            total += matrix[i][dst as usize];
        }
        i = dst as usize;
    }

    total + way_back
}

fn main() {
    let input = include_str!("input.txt");
    let grid: Vec<_> = input
        .trim()
        .lines()
        .map(|l| l.chars().collect::<Vec<char>>())
        .collect();
    let n = input.chars().filter(|c| c.is_numeric()).count();

    let mut points = vec![(0, 0); n];
    for y in 0..grid.len() {
        for x in 0..grid[0].len() {
            let cell = grid[y][x];
            if cell.is_numeric() {
                let val = cell as u8 - '0' as u8;
                points[val as usize] = (x, y);
            }
        }
    }

    let matrix: Vec<_> = (0..n)
        .into_iter()
        .map(|i| find_neighbors(n, points[i], &grid))
        .collect();

    let p1 = (1..n)
        .permutations(n - 1)
        .map(|way| way_len(way, &matrix))
        .filter(|len| *len > 0)
        .min()
        .unwrap();

    let p2 = (1..n)
        .permutations(n - 1)
        .map(|way| way_len_with_return(way, &matrix))
        .filter(|len| *len > 0)
        .min()
        .unwrap();

    println!("Part1: {}", p1);
    println!("Part2: {}", p2);
}
