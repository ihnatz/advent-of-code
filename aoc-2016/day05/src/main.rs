use md5::{Digest, Md5};

const INPUT: &str = "ugkcyxxp";

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

fn main() {
    let part1: String = (0..)
        .map(|i| format!("{INPUT}{i}"))
        .filter_map(|candidate| verify(&candidate, false).map(|(_, ch)| ch))
        .take(8)
        .collect();

    println!("Part1: {part1}");

    let mut part2 = [' '; 8];
    let mut found = 0;

    for i in 0.. {
        let candidate = format!("{INPUT}{i}");
        if let Some((idx, ch)) = verify(&candidate, true) {
            if part2[idx] == ' ' {
                part2[idx] = ch;
                found += 1;
                if found == 8 {
                    break;
                }
            }
        }
    }

    println!("Part2: {}", part2.iter().collect::<String>());
}
