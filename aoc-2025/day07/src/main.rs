use std::collections::HashSet;
use std::collections::HashMap;

type Coord = (usize, usize);

fn print(stopped: &HashSet<Coord>, splitters: &HashSet<Coord>) {
    let mut max_row = 0;
    let mut max_col = 0;
    for (row, col) in stopped {
        if *row > max_row {
            max_row = *row;
        }
        if *col > max_col {
            max_col = *col;
        }
    }

    for row in 0..=max_row {
        for col in 0..=max_col {
            let cur = (row, col);
            if stopped.contains(&cur) {
                print!("|");
            } else if splitters.contains(&cur) {
                print!("^")
            } else {
                print!(".")
            }
        }
        println!("");
    }
}

fn splits_count(manifold_size: usize, start: Coord, splitters: &HashSet<Coord>) -> usize {
    let mut running: HashSet<Coord> = HashSet::new();
    let mut stopped: HashSet<Coord> = HashSet::new();

    running.insert(start);

    while !running.is_empty() {
        let mut new_running: HashSet<Coord> = HashSet::new();
        for (row, col) in running {
            if (row + 1) == manifold_size {
                continue;
            }
            let next_cell = (row + 1, col);
            if splitters.contains(&next_cell) {
                stopped.insert((row, col));
                let left_split = (row, col - 1);
                let right_split = (row, col + 1);
                if !splitters.contains(&left_split) {
                    new_running.insert(left_split);
                }
                if !splitters.contains(&right_split) {
                    new_running.insert(right_split);
                }
            } else {
                new_running.insert(next_cell);
            }
        }
        running = new_running;
    }

    print(&stopped, &splitters);
    stopped.len()
}

fn main() {
    let input = include_str!("input.txt");
    let mut splitters: HashSet<Coord> = HashSet::new();
    let mut start: Coord = (0, 0);

    for (row, line) in input.lines().enumerate() {
        for (col, ch) in line.chars().into_iter().enumerate() {
            match ch {
                'S' => start = (row + 1, col),
                '^' => {
                    splitters.insert((row, col));
                }
                _ => {}
            };
        }
    }
    let manifold_size = input.lines().count();

    println!("Part1: {:?}", splits_count(manifold_size, start, &splitters));


    let mut running: HashMap<Coord, usize> = HashMap::new();
    let mut stopped: HashSet<Coord> = HashSet::new();

    running.insert(start, 1);

    let mut t = 0;

    while !running.is_empty() {
        let mut new_running: HashMap<Coord, usize> = HashMap::new();
        for ((row, col), val) in running {
            if (row + 1) == manifold_size {
                t += val;
                continue;
            }
            let next_cell = (row + 1, col);
            if splitters.contains(&next_cell) {
                stopped.insert((row, col));
                let left_split = (row, col - 1);
                if !splitters.contains(&left_split) {
                    new_running
                        .entry(left_split)
                        .and_modify(|count| *count += val)
                        .or_insert(val);
                }
                let right_split = (row, col + 1);
                if !splitters.contains(&right_split) {
                    new_running
                        .entry(right_split)
                        .and_modify(|count| *count += val)
                        .or_insert(val);
                }
            } else {

                 new_running
                        .entry(next_cell)
                        .and_modify(|count| *count += val)
                        .or_insert(val);
            }
        }
        running = new_running;
    }
    println!("Part2: {:?}", t);
}
