use std::collections::HashSet;
use std::process::Command;
use std::thread;
use std::time::Duration;

type Point = (i32, i32);
const DEBUG: bool = false;

fn print_debug(val: &str) {
    if DEBUG {
        println!("{val}");
    }
}

fn print_map(
    count: usize,
    boxesl: &HashSet<Point>,
    boxesr: &HashSet<Point>,
    walls: &HashSet<Point>,
    current: Point,
) {
    if !DEBUG {
        return;
    }

    Command::new("clear").status().unwrap();

    let max_x = walls.iter().map(|x| x.0).max().unwrap();
    let max_y = walls.iter().map(|x| x.1).max().unwrap();

    println!("Iteration #{:?}", count);

    for y in 0..max_y + 1 {
        print!("{: >3} ", y);
        for x in 0..max_x + 1 {
            let point = (x, y);

            if boxesl.contains(&point) {
                print!("[");
            } else if boxesr.contains(&point) {
                print!("]");
            } else if walls.contains(&point) {
                print!("#");
            } else if current == point {
                print!("@");
            } else {
                print!(".");
            }
        }
        println!();
    }
    println!();

    thread::sleep(Duration::from_millis(100));

    for l in boxesl {
        let r = (l.0 + 1, l.1);
        if !boxesr.contains(&r) {
            panic!("unmatched [");
        }
    }

    for r in boxesr {
        let l = (r.0 - 1, r.1);
        if !boxesl.contains(&l) {
            panic!("unmatched ]");
        }
    }

    if boxesl.contains(&current) || boxesr.contains(&current) || walls.contains(&current) {
        panic!();
    }
}

fn box_coordinates(
    cell: Point,
    boxesl: &HashSet<Point>,
    boxesr: &HashSet<Point>,
) -> (Point, Point) {
    if boxesr.contains(&cell) {
        ((cell.0 - 1, cell.1), cell)
    } else {
        if !boxesl.contains(&cell) {
            panic!("unknown cell, not a box");
        }
        (cell, (cell.0 + 1, cell.1))
    }
}

fn main() {
    let input = include_str!("input.txt");
    let (grid, steps) = input.split_once("\n\n").unwrap();

    let mut boxesl = HashSet::new();
    let mut boxesr = HashSet::new();
    let mut walls = HashSet::new();
    let mut occupied = HashSet::new();

    let mut current = (0, 0);
    for (y, line) in grid.lines().enumerate() {
        for (x, cell) in line.bytes().enumerate() {
            let x = x as i32 * 2;
            let y = y as i32;
            match cell {
                b'O' => {
                    boxesl.insert((x, y));
                    boxesr.insert((x + 1, y));
                    occupied.insert((x, y));
                    occupied.insert((x + 1, y));
                }
                b'#' => {
                    walls.insert((x, y));
                    walls.insert((x + 1, y));
                }
                b'@' => {
                    current = (x, y);
                }
                b'.' => (),
                _ => unreachable!(),
            }
        }
    }

    let mut count = 0;
    for step in steps.replace("\n", "").bytes() {
        count += 1;

        let (x, y) = current;
        let (dx, dy) = match step {
            b'^' => (0, -1),
            b'>' => (1, 0),
            b'v' => (0, 1),
            b'<' => (-1, 0),
            _ => unreachable!(),
        };
        let destination = (x + dx, y + dy);

        print_debug(&format!("Destination {:?}", destination));
        print_debug(&format!("Move {:?}", step as char));

        if walls.contains(&destination) {
            print_debug("Hit the wall");
            print_map(count, &boxesl, &boxesr, &walls, current);
            continue;
        }

        if occupied.contains(&destination) {
            let current_box = box_coordinates(destination, &boxesl, &boxesr);

            let push_box = if step == b'<' || step == b'>' {
                print_debug("Move horizontally");

                let mut current_cell = destination;
                let mut stack: Vec<_> = vec![];
                while occupied.contains(&current_cell) {
                    stack.push(current_cell);
                    current_cell = (current_cell.0 + dx, current_cell.1 + dy);
                }

                let last_occupied = stack.last().expect("can't be less than 1 box");
                let next_box_cell = (last_occupied.0 + dx, last_occupied.1 + dy);
                if occupied.contains(&next_box_cell) || walls.contains(&next_box_cell) {
                    continue;
                }

                stack
                    .iter()
                    .map(|point| box_coordinates(*point, &boxesl, &boxesr))
                    .collect::<HashSet<(Point, Point)>>()
            } else {
                print_debug("Move vertically");
                let mut push_box = HashSet::new();
                let mut push_line = HashSet::new();
                let mut new_line = HashSet::new();

                push_box.insert(current_box);
                push_line.insert(current_box.0);
                push_line.insert(current_box.1);
                let mut can_move = true;
                loop {
                    for cell in push_line.clone().into_iter() {
                        let next_cell = (cell.0 + dx, cell.1 + dy);
                        if occupied.contains(&next_cell) {
                            let b = box_coordinates(next_cell, &boxesl, &boxesr);
                            push_box.insert(b);
                            new_line.insert(b.0);
                            new_line.insert(b.1);
                        }
                        if walls.contains(&next_cell) {
                            can_move = false;
                            break;
                        }
                    }
                    if !can_move || new_line.is_empty() {
                        break;
                    } else {
                        push_line = new_line;
                        new_line = HashSet::new();
                    }
                }

                if can_move {
                    print_debug("So, we can move this");
                } else {
                    print_debug("No way I can move it");
                    continue;
                }
                push_box
            };

            for b in push_box.iter() {
                occupied.remove(&b.0);
                occupied.remove(&b.1);
                boxesl.remove(&b.0);
                boxesr.remove(&b.1);
            }

            for b in push_box.clone().into_iter() {
                let (mut l, mut r) = b;
                l = (l.0 + dx, l.1 + dy);
                r = (r.0 + dx, r.1 + dy);

                occupied.insert(l);
                occupied.insert(r);
                boxesl.insert(l);
                boxesr.insert(r);
            }

            current = destination;

            print_debug(&format!("Move {:?}", step as char));
            print_debug("Moved the box");
            print_map(count, &boxesl, &boxesr, &walls, current);
            continue;
        }
        current = destination;

        print_debug(&format!("Move {:?}", step as char));
        print_debug("Moved myself");
        print_map(count, &boxesl, &boxesr, &walls, current);
    }

    let gps = boxesl
        .iter()
        .map(|point| point.1 * 100 + point.0)
        .sum::<i32>();
    println!("{gps}");
}
