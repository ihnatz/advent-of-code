use std::collections::{HashSet, LinkedList};

const SEED: i32 = 1362;
const FINISH: (i32, i32) = (31, 39);
const MAX_STEPS: i32 = 50;

const MOVES: [(i32, i32); 4] = [(0, 1), (1, 0), (-1, 0), (0, -1)];
const CELL: i32 = 100;

fn is_obsticle(x: i32, y: i32) -> bool {
    let val = x * x + 3 * x + 2 * x * y + y + y * y + SEED;
    val.count_ones() % 2 == 1
}

fn generate_map() -> HashSet<(i32, i32)> {
    let mut obsticles = HashSet::new();
    for y in 0..CELL {
        for x in 0..CELL {
            let val = is_obsticle(x, y);
            if val {
                obsticles.insert((x, y));
            }
        }
    }
    obsticles
}

fn shortest_path(obsticles: &HashSet<(i32, i32)>) -> i32 {
    let start = (1, 1, 0);
    let mut q = LinkedList::new();
    let mut known_states = HashSet::new();
    let mut total_steps = 0;

    q.push_front(start);
    while !q.is_empty() {
        let current = q.pop_front().unwrap();
        if known_states.contains(&current) {
            continue;
        }
        known_states.insert(current);
        let (x, y, steps) = current;
        if (x, y) == FINISH {
            total_steps = steps;
            break;
        }

        for (dx, dy) in MOVES {
            let nx = x + dx;
            let ny = y + dy;
            if nx >= 0 && ny >= 0 && !obsticles.contains(&(nx, ny)) {
                q.push_back((nx, ny, steps + 1));
            }
        }
    }

    total_steps
}

fn cells_visited(obsticles: &HashSet<(i32, i32)>) -> i32 {
    let start = (1, 1, 0);
    let mut q = LinkedList::new();
    let mut known_states = HashSet::new();
    let mut visited = HashSet::new();

    q.push_front(start);
    while !q.is_empty() {
        let current = q.pop_front().unwrap();
        if known_states.contains(&current) {
            continue;
        }
        known_states.insert(current);
        let (x, y, steps) = current;
        if steps > MAX_STEPS {
            continue;
        };
        visited.insert((x, y));

        for (dx, dy) in MOVES {
            let nx = x + dx;
            let ny = y + dy;
            if nx >= 0 && ny >= 0 && !obsticles.contains(&(nx, ny)) {
                q.push_back((nx, ny, steps + 1));
            }
        }
    }

    visited.len() as i32
}

fn main() {
    let obsticles = generate_map();

    println!("Part1: {}", shortest_path(&obsticles));
    println!("Part2: {}", cells_visited(&obsticles));
}
