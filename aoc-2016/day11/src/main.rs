use itertools::Itertools;
use regex::Regex;
use std::collections::{BTreeSet, HashSet, LinkedList};

const FLOORS: usize = 3;

type Floor = (BTreeSet<u8>, BTreeSet<u8>);
type State = (Vec<Floor>, usize, Floor);

#[derive(Hash, Eq, PartialEq, Clone)]
struct CompactState {
    elevator: usize,
    pairs: Vec<(usize, usize)>,
}

impl CompactState {
    fn from_state(state: &State) -> Self {
        let (floors, elevator, lift) = state;
        let gs: Vec<_> = floors.iter().flat_map(|floor| floor.1.clone()).collect();

        let mut pairs = Vec::new();

        for elem in gs {
            let gen_floor = (0..=FLOORS)
                .find(|&f| {
                    floors[f].1.contains(&elem) || (f == *elevator && lift.1.contains(&elem))
                })
                .unwrap_or(0);

            let chip_floor = (0..=FLOORS)
                .find(|&f| {
                    floors[f].0.contains(&elem) || (f == *elevator && lift.0.contains(&elem))
                })
                .unwrap_or(0);

            pairs.push((gen_floor, chip_floor));
        }
        pairs.sort();

        CompactState {
            elevator: *elevator,
            pairs,
        }
    }
}

fn parse_map(input: &str) -> (Vec<Floor>, BTreeSet<String>) {
    let mut elements: BTreeSet<String> = BTreeSet::new();

    for line in input.trim().lines() {
        let microchip_pattern = Regex::new(r"(\w+)-compatible microchip").unwrap();
        let generator_pattern = Regex::new(r"(\w+) generator").unwrap();

        for cap in microchip_pattern.captures_iter(line) {
            if let Some(element) = cap.get(1) {
                elements.insert(element.as_str().to_string());
            }
        }
        for cap in generator_pattern.captures_iter(line) {
            if let Some(element) = cap.get(1) {
                elements.insert(element.as_str().to_string());
            }
        }
    }

    let floors = input
        .trim()
        .lines()
        .map(|line| parse_floor_contents(&elements, line))
        .collect();

    (floors, elements)
}

fn parse_floor_contents(elements: &BTreeSet<String>, input: &str) -> Floor {
    let microchip_pattern = Regex::new(r"(\w+)-compatible microchip").unwrap();
    let generator_pattern = Regex::new(r"(\w+) generator").unwrap();

    let mut microchips = BTreeSet::new();
    let mut generators = BTreeSet::new();

    for cap in microchip_pattern.captures_iter(input) {
        if let Some(element) = cap.get(1) {
            let idx = elements.iter().position(|e| e == element.as_str()).unwrap() as u8;
            microchips.insert(idx);
        }
    }

    for cap in generator_pattern.captures_iter(input) {
        if let Some(element) = cap.get(1) {
            let idx = elements.iter().position(|e| e == element.as_str()).unwrap() as u8;
            generators.insert(idx);
        }
    }

    (microchips, generators)
}

fn floor_items(floor: usize, floors: &[Floor], current: usize, lift: &Floor) -> Floor {
    if floor != current {
        floors[floor].clone()
    } else {
        let (fm, fg) = floors[current].clone();
        let (lm, lg) = lift.clone();
        (
            fm.union(&lm).cloned().collect(),
            fg.union(&lg).cloned().collect(),
        )
    }
}

fn is_valid_floor(floor: usize, floors: &[Floor], current: usize, lift: &Floor) -> bool {
    let (m, g) = floor_items(floor, floors, current, lift);
    let covered: BTreeSet<_> = m.intersection(&g).cloned().collect();
    let uncovered_gs: BTreeSet<_> = g.difference(&covered).cloned().collect();
    uncovered_gs.is_empty() || m.is_empty()
}


fn is_valid_state(s: &State) -> bool {
    let (floors, current, lift) = s;
    let items_in_lift = lift.0.len() + lift.1.len();
    *current <= FLOORS
        && items_in_lift <= 2
        && (0..=FLOORS).all(|floor| is_valid_floor(floor, floors, *current, lift))
}

fn is_finished(floors: &[Floor], current: usize, lift: &Floor) -> bool {
    current == FLOORS
        && (0..=FLOORS - 1).all(|floor| floors[floor].0.is_empty() && floors[floor].1.is_empty())
        && is_valid_floor(FLOORS, floors, current, lift)
}

fn run_flors(floors: Vec<Floor>) -> i32 {
    let lift: Floor = (BTreeSet::new(), BTreeSet::new());
    let initial = (floors, 0, lift);

    let mut q = LinkedList::new();
    let mut visited: HashSet<CompactState> = HashSet::new();
    let mut total = 0;

    q.push_back((initial.clone(), 0));
    visited.insert(CompactState::from_state(&initial));

    while !q.is_empty() {
        let (state, steps) = q.pop_front().unwrap();
        let (ref floors, current, ref lift) = state;

        if is_finished(floors, current, lift) {
            total = steps;
            break;
        }

        let (nm, ng) = floor_items(current, floors, current, lift);

        // Try moving two microchips
        for ms in nm.iter().combinations(2) {
            let m1 = ms[0];
            let m2 = ms[1];

            let mut new_floors = floors.clone();
            let mut new_current = new_floors[current].clone();

            for m in lift.0.iter() {
                new_current.0.insert(*m);
            }
            for g in lift.1.iter() {
                new_current.1.insert(*g);
            }

            new_current.0.remove(m1);
            new_current.0.remove(m2);
            new_floors[current] = new_current;

            let new_lift = (BTreeSet::from([*m1, *m2]), BTreeSet::new());

            let new_state = (new_floors.clone(), current - 1, new_lift.clone());
            if is_valid_state(&new_state) {
                let compact = CompactState::from_state(&new_state);
                if !visited.contains(&compact) {
                    q.push_back((new_state, steps + 1));
                    visited.insert(compact);
                }
            }

            let new_state = (new_floors.clone(), current + 1, new_lift.clone());
            if is_valid_state(&new_state) {
                let compact = CompactState::from_state(&new_state);
                if !visited.contains(&compact) {
                    q.push_back((new_state, steps + 1));
                    visited.insert(compact);
                }
            }
        }

        // Try moving one microchip
        for m in nm.iter() {
            let mut new_floors = floors.clone();
            let mut new_current = new_floors[current].clone();

            for m in lift.0.iter() {
                new_current.0.insert(*m);
            }
            for g in lift.1.iter() {
                new_current.1.insert(*g);
            }

            new_current.0.remove(m);
            new_floors[current] = new_current;

            let new_lift = (BTreeSet::from([*m]), BTreeSet::new());

            let new_state = (new_floors.clone(), current - 1, new_lift.clone());
            if is_valid_state(&new_state) {
                let compact = CompactState::from_state(&new_state);
                if !visited.contains(&compact) {
                    q.push_back((new_state, steps + 1));
                    visited.insert(compact);
                }
            }

            let new_state = (new_floors.clone(), current + 1, new_lift.clone());
            if is_valid_state(&new_state) {
                let compact = CompactState::from_state(&new_state);
                if !visited.contains(&compact) {
                    q.push_back((new_state, steps + 1));
                    visited.insert(compact);
                }
            }
        }

        // Try moving two generators
        for gs in ng.iter().combinations(2) {
            let g1 = gs[0];
            let g2 = gs[1];

            let mut new_floors = floors.clone();
            let mut new_current = new_floors[current].clone();

            for m in lift.0.iter() {
                new_current.0.insert(*m);
            }
            for g in lift.1.iter() {
                new_current.1.insert(*g);
            }

            new_current.1.remove(g1);
            new_current.1.remove(g2);
            new_floors[current] = new_current;

            let new_lift = (BTreeSet::new(), BTreeSet::from([*g1, *g2]));

            let new_state = (new_floors.clone(), current - 1, new_lift.clone());
            if is_valid_state(&new_state) {
                let compact = CompactState::from_state(&new_state);
                if !visited.contains(&compact) {
                    q.push_back((new_state, steps + 1));
                    visited.insert(compact);
                }
            }

            let new_state = (new_floors.clone(), current + 1, new_lift.clone());
            if is_valid_state(&new_state) {
                let compact = CompactState::from_state(&new_state);
                if !visited.contains(&compact) {
                    q.push_back((new_state, steps + 1));
                    visited.insert(compact);
                }
            }
        }

        // Try moving one generator
        for g in ng.iter() {
            let mut new_floors = floors.clone();
            let mut new_current = new_floors[current].clone();

            for m in lift.0.iter() {
                new_current.0.insert(*m);
            }
            for g in lift.1.iter() {
                new_current.1.insert(*g);
            }

            new_current.1.remove(g);
            new_floors[current] = new_current;

            let new_lift = (BTreeSet::new(), BTreeSet::from([*g]));

            let new_state = (new_floors.clone(), current - 1, new_lift.clone());
            if is_valid_state(&new_state) {
                let compact = CompactState::from_state(&new_state);
                if !visited.contains(&compact) {
                    q.push_back((new_state, steps + 1));
                    visited.insert(compact);
                }
            }

            let new_state = (new_floors.clone(), current + 1, new_lift.clone());
            if is_valid_state(&new_state) {
                let compact = CompactState::from_state(&new_state);
                if !visited.contains(&compact) {
                    q.push_back((new_state, steps + 1));
                    visited.insert(compact);
                }
            }
        }

        // Try moving matching pairs
        let matched: Vec<_> = ng.intersection(&nm.clone()).cloned().collect();
        for mg in matched {
            let mut new_floors = floors.clone();
            let mut new_current = new_floors[current].clone();

            for m in lift.0.iter() {
                new_current.0.insert(*m);
            }
            for g in lift.1.iter() {
                new_current.1.insert(*g);
            }

            new_current.0.remove(&mg);
            new_current.1.remove(&mg);
            new_floors[current] = new_current;

            let new_lift = (BTreeSet::from([mg]), BTreeSet::from([mg]));

            let new_state = (new_floors.clone(), current - 1, new_lift.clone());
            if is_valid_state(&new_state) {
                let compact = CompactState::from_state(&new_state);
                if !visited.contains(&compact) {
                    q.push_back((new_state, steps + 1));
                    visited.insert(compact);
                }
            }

            let new_state = (new_floors.clone(), current + 1, new_lift.clone());
            if is_valid_state(&new_state) {
                let compact = CompactState::from_state(&new_state);
                if !visited.contains(&compact) {
                    q.push_back((new_state, steps + 1));
                    visited.insert(compact);
                }
            }
        }
    }

    total
}

fn main() {
    let input = include_str!("input.txt");
    let (mut floors, elements) = parse_map(input);
    println!("Part1: {}", run_flors(floors.clone()));

    let elerium_idx = (elements.len() + 1) as u8;
    let dilithium_idx = (elements.len() + 2) as u8;
    floors[0].0.insert(elerium_idx);
    floors[0].0.insert(dilithium_idx);
    floors[0].1.insert(elerium_idx);
    floors[0].1.insert(dilithium_idx);
    println!("Part2: {}", run_flors(floors));
}
