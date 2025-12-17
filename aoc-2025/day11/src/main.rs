#![allow(dead_code)]
#![allow(unused_variables)]

use std::collections::HashMap;
fn main() {
    let input = include_str!("input.txt");
    let connections = input
        .lines()
        .map(|line| {
            let (l, r) = line.split_once(": ").unwrap();
            (l, r.split(" ").collect::<Vec<_>>())
        })
        .collect::<HashMap<&str, Vec<&str>>>();

    let mut cache: HashMap<(&str, &str), usize> = HashMap::new();
    println!("Part1: {:?}", dfs(&connections, "you", "out", &mut cache));

    let part2 = dfs(&connections, "svr", "dac", &mut cache)
        * dfs(&connections, "dac", "fft", &mut cache)
        * dfs(&connections, "fft", "out", &mut cache)
        + dfs(&connections, "svr", "fft", &mut cache)
            * dfs(&connections, "fft", "dac", &mut cache)
            * dfs(&connections, "dac", "out", &mut cache);

    println!("Part2: {:?}", part2);
}

fn dfs<'a>(
    connections: &HashMap<&str, Vec<&'a str>>,
    current: &'a str,
    finish: &'a str,
    cache: &mut HashMap<(&'a str, &'a str), usize>,
) -> usize {
    if current == finish {
        return 1;
    }
    if !connections.contains_key(current) {
        return 0;
    }

    let key = (current, finish);
    if let Some(&cached) = cache.get(&key) {
        return cached;
    }

    let count = connections
        .get(current)
        .unwrap()
        .iter()
        .map(|new_current| dfs(connections, new_current, finish, cache))
        .sum::<usize>();

    cache.insert(key, count);
    count
}
