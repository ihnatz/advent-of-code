use std::collections::{HashSet, VecDeque};
use std::fmt;
use std::{collections::HashMap, fmt::Display, fmt::Formatter};

const DIRECTIONS: [(i32, i32); 4] = [(0, -1), (1, 0), (0, 1), (-1, 0)];

#[derive(Debug, Eq, PartialEq, Hash, Clone, Copy)]
struct Point {
    x: i32,
    y: i32,
}

#[derive(Debug)]
struct FileInfo {
    size: u16,
    used: u16,
    avail: u16,
}

fn parse_line(line: &str) -> Option<(Point, FileInfo)> {
    let parts: Vec<_> = line.split_whitespace().collect();
    let [name, size, used, avail, _] = parts.as_slice() else {
        panic!()
    };
    let parts: Vec<&str> = name.split("-").collect();
    let [_, xs, ys] = parts.as_slice() else {
        panic!()
    };
    let x = xs[1..].parse().ok()?;
    let y = ys[1..].parse().ok()?;
    let size: u16 = size[0..size.len() - 1].parse().ok()?;
    let used: u16 = used[0..used.len() - 1].parse().ok()?;
    let avail: u16 = avail[0..avail.len() - 1].parse().ok()?;

    Some((Point { x, y }, FileInfo { size, used, avail }))
}

#[derive(Debug)]
struct Grid {
    grid: HashMap<Point, FileInfo>,
}

impl Grid {
    fn new(input: &str) -> Self {
        let mut grid = HashMap::new();
        input.lines().skip(2).for_each(|line| {
            let (point, info) = parse_line(line).unwrap();
            grid.insert(point, info);
        });
        Grid { grid }
    }

    fn viable_pairs(&self, pointa: &Point) -> usize {
        let a = self.at(pointa);
        self.grid
            .iter()
            .filter(|(&pointb, b)| pointb != *pointa && a.used > 0 && a.used <= b.avail)
            .count()
    }

    fn at(&self, point: &Point) -> &FileInfo {
        self.grid.get(point).unwrap()
    }

    fn points(&self) -> impl Iterator<Item = &Point> {
        self.grid.keys()
    }
}

impl Display for Grid {
    fn fmt(&self, f: &mut Formatter<'_>) -> fmt::Result {
        let max_x = self.grid.keys().map(|p| p.x).max().unwrap();
        let max_y = self.grid.keys().map(|p| p.y).max().unwrap();

        for y in 0..=max_y {
            for x in 0..=max_x {
                let point = Point { x, y };
                if let Some(file) = self.grid.get(&point) {
                    write!(f, "{} ", file)?;
                }
            }
            writeln!(f)?;
        }
        Ok(())
    }
}

fn print_grid(grid: &Grid, current: Point) {
    let max_x = grid.grid.keys().map(|p| p.x).max().unwrap();
    let max_y = grid.grid.keys().map(|p| p.y).max().unwrap();

    for y in 0..=max_y {
        for x in 0..=max_x {
            let point = Point { x, y };
            let file = grid.at(&point);
            if current.x == x && current.y == y {
                print!("C");
            } else if x == max_x && y == 0 {
                print!("G");
            } else if file.size > 100 {
                print!("#");
            } else if file.used == 0 {
                print!("_");
            } else {
                print!(".");
            }
        }
        println!();
    }
    println!();
}

impl Display for FileInfo {
    fn fmt(&self, f: &mut Formatter<'_>) -> fmt::Result {
        write!(f, "{: >3}/{: >3}", self.used, self.size)?;
        Ok(())
    }
}

fn find_path(grid: &Grid, start: Point) -> Option<(Point, usize)> {
    let mut q = VecDeque::new();
    let mut visited = HashSet::new();
    q.push_back((start, 0));

    while !q.is_empty() {
        let (point, steps) = q.pop_front().unwrap();

        if visited.contains(&point) {
            continue;
        }
        visited.insert(point);

        if point.y == 0 {
            return Some((point, steps));
        }

        let current_file = grid.at(&point);
        for (dx, dy) in DIRECTIONS {
            let new_point = Point {
                x: point.x + dx,
                y: point.y + dy,
            };
            if grid.grid.contains_key(&new_point) {
                let neigh = grid.at(&new_point);
                if neigh.used <= current_file.size {
                    q.push_back((new_point, steps + 1));
                }
            }
        }
    }
    None
}

fn main() {
    println!("Hello, world!");
    let input = include_str!("input.txt");
    let grid = Grid::new(input);

    let total = grid
        .points()
        .into_iter()
        .map(|point| grid.viable_pairs(point) as u64)
        .sum::<u64>();
    println!("Part1: {}", total);

    let empty = grid.points().find(|f| grid.at(f).used == 0).unwrap();
    let (point, steps) = find_path(&grid, *empty).unwrap();

    let cols = grid.grid.keys().map(|p| p.x).max().unwrap() + 1;
    let total_steps = steps as i32 + (cols - point.x - 1) + 5 * (cols - 2);
    println!("Part2: {}", total_steps);
}
