use priority_queue::PriorityQueue;
use std::cmp::Reverse;
use std::collections::HashMap;
use std::collections::HashSet;

type Pos = (i32, i32);

const DIRECTIONS: [Pos; 4] = [(0, -1), (1, 0), (0, 1), (-1, 0)];
const INF: u64 = u64::MAX;

// const SIDE: usize = 6; const LIMIT: usize = 12;
const SIDE: usize = 70;
const LIMIT: usize = 1024;
const H: usize = SIDE + 1;
const W: usize = SIDE + 1;

const STEP_COST: u64 = 1;

#[derive(Debug, Clone, Copy, Eq, PartialEq, Hash)]
struct State {
    pos: Pos,
    cost: u64,
}

#[inline]
fn clamp(p: Pos) -> Option<Pos> {
    let width = W;
    let height = H;
    let (x, y) = p;
    if x < 0 || y < 0 || !(0..width as i32).contains(&x) || !(0..height as i32).contains(&y) {
        return None;
    }
    Some((x as i32, y as i32))
}

fn print_map(walls: &HashSet<Pos>, came_from: HashSet<Pos>) {
    for y in 0..H {
        print!("{: >3} ", y);
        for x in 0..W {
            let point = (x as i32, y as i32);

            if walls.contains(&point) {
                print!("#");
            } else if came_from.contains(&point) {
                print!("O");
            } else {
                print!(".");
            }
        }
        println!();
    }
    println!();
}

fn solve(start: Pos, finish: Pos, walls: &HashSet<Pos>) -> u64 {
    let mut queue: PriorityQueue<State, Reverse<u64>> = PriorityQueue::new();
    let mut came_from: HashMap<Pos, Pos> = HashMap::new();
    let mut gscore = HashMap::new();

    queue.push(
        State {
            pos: start,
            cost: 0,
        },
        Reverse(0),
    );
    gscore.insert(start, 0);

    let mut optimal_cost = INF;
    let mut visited = HashSet::new();
    while let Some((state, _)) = queue.pop() {
        let state_key = state.pos;

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
            }
            continue;
        }

        for (dx, dy) in DIRECTIONS {
            if let Some(next_pos) = clamp((state.pos.0 + dx, state.pos.1 + dy)) {
                if !walls.contains(&next_pos) {
                    let next_cost = state.cost + STEP_COST;
                    let next_key = next_pos;
                    if next_cost <= *gscore.get(&next_key).unwrap_or(&INF) {
                        came_from.insert(next_pos, state.pos);
                        gscore.insert(next_key, next_cost);
                        queue.push(
                            State {
                                pos: next_pos,
                                cost: next_cost,
                            },
                            Reverse(next_cost),
                        );
                    }
                }
            }
        }
    }

    optimal_cost
}

fn main() {
    let input = include_str!("input.txt");
    let mut walls = HashSet::new();
    let mut start = (0, 0);
    let mut finish = ((H - 1) as i32, (W - 1) as i32);

    let mut exta_walls = vec![];

    let mut c = 0;
    for line in input.trim().lines() {
        c += 1;
        let (x, y) = line.split_once(",").unwrap();
        let x = x.parse::<i32>().unwrap();
        let y = y.parse::<i32>().unwrap();
        if c <= LIMIT {
            walls.insert((x, y));
        } else {
            exta_walls.push((x, y));
        }
    }

    let optimal_cost = solve(start, finish, &walls);
    println!("Part1: {}", optimal_cost);

    for wall in exta_walls {
        walls.insert(wall);
        let optimal_cost = solve(start, finish, &walls);
        if optimal_cost == INF {
            println!("Part2: {},{}", wall.0, wall.1);
            break;
        }
    }
}
