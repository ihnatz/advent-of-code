use priority_queue::PriorityQueue;
use std::cmp::Reverse;
use std::collections::HashMap;
use std::collections::HashSet;

type PosDir = (i32, i32, u8);
type Pos = (i32, i32);

const DIRECTIONS: [Pos; 4] = [(0, -1), (1, 0), (0, 1), (-1, 0)];
const INF: u64 = u64::MAX;

const TURN_COST: u64 = 1_000;
const STEP_COST: u64 = 1;

#[derive(Debug, Clone, Copy, Eq, PartialEq, Hash)]
struct State {
    pos: Pos,
    dir: u8,
    cost: u64,
}

fn collect_paths(
    came_from: &HashMap<PosDir, Vec<PosDir>>,
    current: PosDir,
    optimal_paths: &mut HashSet<Pos>,
) {
    optimal_paths.insert((current.0, current.1));

    if let Some(prevs) = came_from.get(&current) {
        for &prev in prevs {
            collect_paths(came_from, prev, optimal_paths);
        }
    }
}

fn main() {
    let input = include_str!("input.txt");
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

    let mut queue: PriorityQueue<State, Reverse<u64>> = PriorityQueue::new();
    let mut came_from: HashMap<PosDir, Vec<PosDir>> = HashMap::new();
    let mut gscore = HashMap::new();
    let mut optimal_paths = HashSet::new();

    queue.push(
        State {
            pos: start,
            dir: 1,
            cost: 0,
        },
        Reverse(0),
    );
    gscore.insert((start, 1), 0);

    let mut optimal_cost = INF;
    let mut optimal_end_states = Vec::with_capacity(100);

    let mut visited = HashSet::new();

    while let Some((state, _)) = queue.pop() {
        let state_key = (state.pos, state.dir);

        if visited.contains(&state_key) {
            continue;
        }
        visited.insert(state_key);

        if state.cost > optimal_cost {
            break;
        }

        if state.pos == finish {
            if state.cost <= optimal_cost {
                optimal_cost = state.cost;
                optimal_end_states.push((state.pos.0, state.pos.1, state.dir));
            }
            continue;
        }

        let (dx, dy) = DIRECTIONS[state.dir as usize];
        let next_pos = (state.pos.0 + dx, state.pos.1 + dy);

        if !walls.contains(&next_pos) {
            let next_cost = state.cost + STEP_COST;
            let next_key = (next_pos, state.dir);
            if next_cost <= *gscore.get(&next_key).unwrap_or(&INF) {
                if next_cost == *gscore.get(&next_key).unwrap_or(&INF) {
                    came_from
                        .entry((next_pos.0, next_pos.1, state.dir))
                        .or_default()
                        .push((state.pos.0, state.pos.1, state.dir));
                } else {
                    came_from.insert(
                        (next_pos.0, next_pos.1, state.dir),
                        vec![(state.pos.0, state.pos.1, state.dir)],
                    );
                    gscore.insert(next_key, next_cost);
                }
                queue.push(
                    State {
                        pos: next_pos,
                        dir: state.dir,
                        cost: next_cost,
                    },
                    Reverse(next_cost),
                );
            }
        }

        let left = (state.dir + 3) % 4;
        let right = (state.dir + 1) % 4;

        for &new_dir in &[left, right] {
            let next_cost = state.cost + TURN_COST;
            let next_key = (state.pos, new_dir);
            if next_cost <= *gscore.get(&next_key).unwrap_or(&INF) {
                if next_cost == *gscore.get(&next_key).unwrap_or(&INF) {
                    came_from
                        .entry((state.pos.0, state.pos.1, new_dir))
                        .or_default()
                        .push((state.pos.0, state.pos.1, state.dir));
                } else {
                    came_from.insert(
                        (state.pos.0, state.pos.1, new_dir),
                        vec![(state.pos.0, state.pos.1, state.dir)],
                    );
                    gscore.insert(next_key, next_cost);
                }

                queue.push(
                    State {
                        pos: state.pos,
                        dir: new_dir,
                        cost: next_cost,
                    },
                    Reverse(next_cost),
                );
            }
        }
    }

    for end_state in optimal_end_states {
        collect_paths(&came_from, end_state, &mut optimal_paths);
    }

    println!("Part1: {}", optimal_cost);
    println!("Part2: {}", optimal_paths.len());
}
