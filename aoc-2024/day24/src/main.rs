use std::collections::HashMap;
use std::collections::HashSet;
use std::collections::VecDeque;

fn run(instructions: &[(String, String, String, String)], init: &HashMap<String, bool>) -> u64 {
    let mut current = init.clone();
    let mut q = VecDeque::from(instructions.to_owned());

    while let Some((in1, op, in2, out)) = q.pop_front() {
        if current.contains_key(&in1) && current.contains_key(&in2) {
            let v1 = *current.get(&in1).unwrap();
            let v2 = *current.get(&in2).unwrap();
            let v3 = match op.as_str() {
                "XOR" => v1 ^ v2,
                "OR" => v1 || v2,
                "AND" => v1 && v2,
                _ => unreachable!(),
            };
            current.insert(out, v3);
        } else {
            q.push_back((in1, op, in2, out));
        }
    }

    let mut out_keys: Vec<_> = current.keys().filter(|k| k.starts_with("z")).collect();
    out_keys.sort();
    let actual_z_bits: Vec<_> = out_keys
        .into_iter()
        .rev()
        .map(|k| *current.get(k).unwrap())
        .collect();
    actual_z_bits
        .iter()
        .fold(0, |acc, &b| (acc << 1) | (b as u64))
}

fn main() {
    let input = include_str!("input.txt");
    let (state, instructions) = input.split_once("\n\n").unwrap();

    let state: HashMap<String, bool> = state
        .lines()
        .map(|line| {
            let (reg, val) = line.split_once(": ").unwrap();
            (reg.to_string(), val.parse::<i32>().unwrap() == 1)
        })
        .collect();

    let instructions: Vec<_> = instructions
        .lines()
        .map(|line| {
            let parts: Vec<_> = line.split_whitespace().collect();
            (
                parts[0].to_string(),
                parts[1].to_string(),
                parts[2].to_string(),
                parts[4].to_string(),
            )
        })
        .collect();

    let actual_z = run(&instructions, &state);
    println!("Part1: {}", actual_z);

    let mut zs: Vec<_> = instructions
        .iter()
        .filter(|(_, _, _, out)| out.starts_with("z"))
        .map(|(_, _, _, out)| out.clone())
        .collect();
    zs.sort();
    let finishz = zs.last().unwrap();
    let startx = "x00";

    let mut wrong = HashSet::new();
    for (in1, op, in2, out) in &instructions {
        if out.starts_with("z") && op != "XOR" && out != finishz {
            wrong.insert(out);
        }
        if op == "XOR"
            && ![in1, in2, out].iter().any(|s| {
                s.chars()
                    .next()
                    .map(|c| matches!(c, 'x' | 'y' | 'z'))
                    .unwrap()
            })
        {
            wrong.insert(out);
        }
        if op == "AND" && (in1 != startx && in2 != startx) {
            for (sin1, sop, sin2, _) in &instructions {
                if (out == sin1 || out == sin2) && sop != "OR" {
                    wrong.insert(out);
                }
            }
        }
        if op == "XOR" {
            for (sin1, sop, sin2, _) in &instructions {
                if (out == sin1 || out == sin2) && sop == "OR" {
                    wrong.insert(out);
                }
            }
        }
    }

    let mut s = wrong.iter().map(|v| v.to_string()).collect::<Vec<_>>();
    s.sort();
    println!("Part2: {}", s.join(","));
}
