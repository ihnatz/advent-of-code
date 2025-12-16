use std::collections::{HashMap, VecDeque};
fn main() {
    let input = include_str!("input.txt");
    let mut total = 0;
    for line in input.trim().lines() {
        let parts = line.split(" ").collect::<Vec<_>>();
        let signal = parts[0][1..parts[0].len() - 1]
            .chars()
            .map(|c| if c == '#' { '1' } else { '0' })
            .collect::<String>();

        let buttons = parts[1..parts.len() - 1]
            .iter()
            .map(|b| {
                b[1..b.len() - 1]
                    .split(",")
                    .map(|x| x.parse::<usize>().unwrap())
                    .collect::<Vec<_>>()
            })
            .collect::<Vec<_>>();

        total += run(&signal, &buttons);
    }
    println!("Part1: {:?}", total);
}

fn run(expected: &str, buttons: &[Vec<usize>]) -> u16 {
    let start = "0".repeat(expected.len());
    let mut known: HashMap<String, u16> = HashMap::new();
    let mut q = VecDeque::new();

    known.insert(start.clone(), 0);
    q.push_back((start, 0));

    while let Some((current, steps)) = q.pop_front() {
        for button in buttons {
            let new_current = current
                .chars()
                .enumerate()
                .map(|(idx, val)| {
                    if button.contains(&idx) {
                        (1 - val.to_digit(10).unwrap()).to_string()
                    } else {
                        val.to_string()
                    }
                })
                .collect::<Vec<String>>()
                .join("");

            if !known.contains_key(&new_current) {
                    known.insert(new_current.clone(), steps + 1);
                    q.push_back((new_current, steps + 1));
            }
        }
    }

    *known.get(expected).unwrap()
}
