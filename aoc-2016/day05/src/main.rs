use md5::{Digest, Md5};
use std::{sync::mpsc, thread};

const INPUT: &str = "ugkcyxxp";
const WORKERS: u32 = 3;

fn to_hex_string(bytes: &[u8]) -> String {
    bytes
        .iter()
        .fold(String::with_capacity(32), |mut output, &b| {
            use std::fmt::Write;
            let _ = write!(output, "{:02x}", b);
            output
        })
}

fn verify(candidate: &str, part2: bool) -> Option<(usize, char)> {
    let mut hasher = Md5::new();
    hasher.update(candidate);
    let result = hasher.finalize();

    if result[..2] == [0, 0] && result[2] < 16 {
        let hex = to_hex_string(&result);
        let position = hex.chars().nth(5)?.to_digit(16)? as usize;
        let character = hex.chars().nth(6)?;

        if part2 {
            if position < 8 {
                Some((position, character))
            } else {
                None
            }
        } else {
            Some((0, hex.chars().nth(5)?))
        }
    } else {
        None
    }
}

fn solve_part1() -> String {
    let (tx, rx) = mpsc::channel();

    for i in 0..WORKERS {
        let newtx = tx.clone();

        thread::spawn(move || {
            let mut current = i;
            loop {
                if let Some((_, ch)) = verify(&format!("{INPUT}{current}"), false) {
                    newtx.send((current, ch)).unwrap_or_default();
                }
                current += WORKERS;
            }
        });
    }

    let mut collected: Vec<_> = Vec::new();

    for (tick, ch) in rx {
        collected.push((tick, ch));
        if collected.len() == 8 {
            break;
        }
    }

    collected.sort_by_key(|(tick, _ch)| *tick);
    collected.iter().map(|(_tick, ch)| ch).collect::<String>()
}

fn solve_part2() -> String {
    let (tx, rx) = mpsc::channel();

    for i in 0..WORKERS {
        let newtx = tx.clone();

        thread::spawn(move || {
            let mut current = i;
            loop {
                if let Some((idx, ch)) = verify(&format!("{INPUT}{current}"), true) {
                    newtx.send((current, idx, ch)).unwrap_or_default();
                }
                current += WORKERS;
            }
        });
    }

    let mut idxs = [u32::MAX; 8];
    let mut part2 = [' '; 8];
    let mut found = 0;

    for (current, idx, ch) in rx {
        if current < idxs[idx] {
            if part2[idx] == ' ' {
                found += 1;
            }
            part2[idx] = ch;
            idxs[idx] = current;
        }

        if found == 8 {
            break;
        }
    }

    part2.iter().collect::<String>()
}

fn main() {
    println!("Part1: {}", solve_part1());
    println!("Part2: {}", solve_part2());
}
