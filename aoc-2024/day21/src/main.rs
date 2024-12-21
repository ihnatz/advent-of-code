const KB: [[u8; 3]; 4] = [
    [b'7', b'8', b'9'],
    [b'4', b'5', b'6'],
    [b'1', b'2', b'3'],
    [b'X', b'0', b'A'],
];

const KB2: [[u8; 3]; 2] = [[b'X', b'^', b'A'], [b'<', b'v', b'>']];

use std::collections::{HashMap, HashSet, VecDeque};

fn create_km1() -> HashMap<char, (i32, i32)> {
    let mut km1 = HashMap::new();
    km1.insert('^', (1, 0));
    km1.insert('A', (2, 0));
    km1.insert('<', (0, 1));
    km1.insert('v', (1, 1));
    km1.insert('>', (2, 1));
    km1
}

fn create_mk1() -> HashMap<(i32, i32), char> {
    let mut mk1 = HashMap::new();
    mk1.insert((1, 0), '^');
    mk1.insert((2, 0), 'A');
    mk1.insert((0, 1), '<');
    mk1.insert((1, 1), 'v');
    mk1.insert((2, 1), '>');
    mk1
}

fn create_km2() -> HashMap<char, (i32, i32)> {
    let mut km2 = HashMap::new();
    km2.insert('7', (0, 0));
    km2.insert('8', (1, 0));
    km2.insert('9', (2, 0));
    km2.insert('4', (0, 1));
    km2.insert('5', (1, 1));
    km2.insert('6', (2, 1));
    km2.insert('1', (0, 2));
    km2.insert('2', (1, 2));
    km2.insert('3', (2, 2));
    km2.insert('0', (1, 3));
    km2.insert('A', (2, 3));
    km2
}

fn create_mk2() -> HashMap<(i32, i32), char> {
    let mut mk2 = HashMap::new();
    mk2.insert((0, 0), '7');
    mk2.insert((1, 0), '8');
    mk2.insert((2, 0), '9');
    mk2.insert((0, 1), '4');
    mk2.insert((1, 1), '5');
    mk2.insert((2, 1), '6');
    mk2.insert((0, 2), '1');
    mk2.insert((1, 2), '2');
    mk2.insert((2, 2), '3');
    mk2.insert((1, 3), '0');
    mk2.insert((2, 3), 'A');
    mk2
}

#[derive(Hash, Eq, PartialEq, Clone)]
struct State {
    key: char,
    path: String,
}

fn unwrap_pair(
    start: char,
    finish: char,
    km: &HashMap<char, (i32, i32)>,
    mk: &HashMap<(i32, i32), char>,
) -> Vec<String> {
    let mut q: VecDeque<State> = VecDeque::new();
    q.push_back(State {
        key: start,
        path: String::new(),
    });

    let mut visited: HashSet<State> = HashSet::new();
    let mut m = 9999;
    let mut result = Vec::new();

    let directions = vec![(0, -1, '^'), (1, 0, '>'), (0, 1, 'v'), (-1, 0, '<')];

    while let Some(state) = q.pop_front() {
        if visited.contains(&state) {
            continue;
        }
        visited.insert(state.clone());

        if state.path.len() > m {
            continue;
        }

        if state.key == finish {
            m = state.path.len();
            let mut path = state.path.clone();
            path.push('A');
            result.push(path);
            continue;
        }

        let (x, y) = km[&state.key];
        for &(dx, dy, d) in &directions {
            let nx = x + dx;
            let ny = y + dy;
            if let Some(&b) = mk.get(&(nx, ny)) {
                let mut new_path = state.path.clone();
                new_path.push(d);
                q.push_back(State {
                    key: b,
                    path: new_path,
                });
            }
        }
    }
    result
}

fn unwrap(
    s: &str,
    lvls: i32,
    km1: &HashMap<char, (i32, i32)>,
    mk1: &HashMap<(i32, i32), char>,
    cache: &mut HashMap<(String, i32), i64>,
) -> i64 {
    let cache_key = (s.to_string(), lvls);
    if let Some(&result) = cache.get(&cache_key) {
        return result;
    }

    let result = if lvls == 0 {
        s.len() as i64
    } else {
        let s = format!("A{}", s);
        let mut t: i64 = 0_i64;
        for window in s.chars().collect::<Vec<char>>().windows(2) {
            let a = window[0];
            let b = window[1];
            t += unwrap_pair(a, b, km1, mk1)
                .iter()
                .map(|x| unwrap(x, lvls - 1, km1, mk1, cache))
                .min()
                .unwrap_or(0_i64) as i64;
        }
        t
    };

    cache.insert(cache_key, result);
    result
}

fn main() {
    let codes = vec!["964A", "140A", "413A", "670A", "593A"];

    let km1 = create_km1();
    let mk1 = create_mk1();
    let km2 = create_km2();
    let mk2 = create_mk2();
    let mut cache = HashMap::new();

    let n = 2;
    let mut t = 0;
    for code in codes.clone() {
        let l: i32 = code[..3].parse().unwrap();
        let mut prefixes = vec![String::new()];
        let code = format!("A{}", code);
        for window in code.chars().collect::<Vec<char>>().windows(2) {
            let a = window[0];
            let b = window[1];
            let mut new_prefixes = Vec::new();

            for suffix in unwrap_pair(a, b, &km2, &mk2) {
                for prefix in &prefixes {
                    new_prefixes.push(format!("{}{}", prefix, suffix));
                }
            }
            prefixes = new_prefixes;
        }

        t += prefixes
            .iter()
            .map(|c| unwrap(c, n, &km1, &mk1, &mut cache))
            .min()
            .unwrap_or(0)
            * l as i64;
    }
    println!("Part1: {}", t);

    let n = 25;
    let mut t = 0;
    for code in codes {
        let l: i32 = code[..3].parse().unwrap();
        let mut prefixes = vec![String::new()];
        let code = format!("A{}", code);
        for window in code.chars().collect::<Vec<char>>().windows(2) {
            let a = window[0];
            let b = window[1];
            let mut new_prefixes = Vec::new();

            for suffix in unwrap_pair(a, b, &km2, &mk2) {
                for prefix in &prefixes {
                    new_prefixes.push(format!("{}{}", prefix, suffix));
                }
            }
            prefixes = new_prefixes;
        }

        t += prefixes
            .iter()
            .map(|c| unwrap(c, n, &km1, &mk1, &mut cache))
            .min()
            .unwrap_or(0)
            * l as i64;
    }
    println!("Part2: {}", t);
}
