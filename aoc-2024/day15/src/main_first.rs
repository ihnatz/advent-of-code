use std::collections::HashSet;

type Point = (i32, i32);
const DEBUG: bool = false;

fn print_debug(val: &str) {
    if !DEBUG {
        return ();
    }
    println!("{val}");
}

fn print_map(boxes: &HashSet<Point>, walls: &HashSet<Point>, current: Point) {
    if !DEBUG {
        return ();
    }

    let max_x = walls.iter().map(|x| x.0).max().unwrap();
    let max_y = walls.iter().map(|x| x.1).max().unwrap();

    if boxes.contains(&current) || walls.contains(&current) {
        println!("______________________________________________");
        println!("              INVALID STATE                   ");
        println!("______________________________________________");
    }

    for y in 0..max_y + 1 {
        for x in 0..max_x + 1 {
            let point = (x, y);

            if boxes.contains(&point) {
                print!("O");
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
}

fn main() {
    let input = include_str!("input.txt");
    let (grid, steps) = input.split_once("\n\n").unwrap();

    let mut boxes = HashSet::new();
    let mut walls = HashSet::new();
    let mut current = (0, 0);
    for (y, line) in grid.lines().enumerate() {
        for (x, cell) in line.bytes().enumerate() {
            let x = x as i32;
            let y = y as i32;
            match cell {
                b'O' => {
                    boxes.insert((x, y));
                }
                b'#' => {
                    walls.insert((x, y));
                }
                b'@' => {
                    current = (x, y);
                }
                b'.' => (),
                _ => unreachable!(),
            }
        }
    }

    print_debug("Start");
    print_map(&boxes, &walls, current);

    let steps = steps.replace("\n", "");
    for step in steps.bytes() {
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

        let is_wall = walls.contains(&destination);
        if is_wall {
            print_debug(&format!("Move {:?}", step as char));
            print_debug("Hit the wall");
            print_map(&boxes, &walls, current);

            continue; // can't move myself
        }
        let is_box = boxes.contains(&destination);
        if is_box {
            let mut current_box = destination;
            let mut stack = vec![];
            while boxes.contains(&current_box) {
                stack.push(current_box);
                current_box = (current_box.0 + dx, current_box.1 + dy);
            }

            if stack.len() == 1 {
                print_debug("Just one box, easy to move");
                let next_box_cell = (x + dx + dx, y + dy + dy);
                if boxes.contains(&next_box_cell) || walls.contains(&next_box_cell) {
                    continue; // can't move box
                }
                boxes.remove(&destination);
                boxes.insert(next_box_cell);
                current = destination;
            } else {
                print_debug("Oh no, we have a stack!");
                print_debug(&format!("Boxes {:?}", stack));
                let first_box = stack.first().expect("can't be less than 1 box");
                let last_box = stack.last().expect("can't be less than 1 box");
                let next_cell = (last_box.0 + dx, last_box.1 + dy);
                if walls.contains(&next_cell) {
                    // can't move boxes
                    continue;
                } else {
                    // will move
                    boxes.remove(&first_box);
                    boxes.insert(next_cell);
                    current = destination;
                }
            }

            print_debug(&format!("Move {:?}", step as char));
            print_debug("Moved the box");
            print_map(&boxes, &walls, current);
            continue;
        }
        // now just move I assume
        current = destination;

        print_debug(&format!("Move {:?}", step as char));
        print_debug("Moved myself");
        print_map(&boxes, &walls, current);
    }

    let gps = boxes
        .iter()
        .map(|point| point.1 * 100 + point.0)
        .sum::<i32>();
    println!("{gps}");
}
