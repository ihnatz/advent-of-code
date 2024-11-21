use md5::{Digest, Md5};
use std::collections::VecDeque;
const PASSCODE: &str = "gdjjyniy";

#[inline]
fn directions(input: &str) -> (bool, bool, bool, bool) {
    let mut hasher = Md5::new();
    hasher.update(PASSCODE.as_bytes());
    hasher.update(input);
    let bytes: [u8; 16] = hasher.finalize().into();

    let up = (bytes[0] >> 4) > 10;
    let right = (bytes[1] & 0xf) > 10;
    let down = (bytes[0] & 0xf) > 10;
    let left = (bytes[1] >> 4) > 10;

    (up, right, down, left)
}

fn main() {
    let mut q = VecDeque::with_capacity(1000);
    q.push_front((String::from(""), 0, 0));

    let mut longest = 0;

    while !q.is_empty() {
        let (current, y, x) = q.pop_front().unwrap();

        if (x, y) == (3, 3) {
            if longest == 0 {
                println!("Part1: {}", current);
            }
            if current.len() > longest {
                longest = current.len();
            }
            continue;
        }

        let (u, r, d, l) = directions(&current);
        for (dx, dy, enabled, letter) in vec![
            (0, -1, u, 'U'),
            (1, 0, r, 'R'),
            (0, 1, d, 'D'),
            (-1, 0, l, 'L'),
        ] {
            if !enabled {
                continue;
            }

            let nx = x + dx;
            let ny = y + dy;

            if nx >= 0 && nx < 4 && ny >= 0 && ny < 4 {
                let new_state = format!("{}{}", current, letter);
                q.push_back((new_state, ny, nx));
            }
        }
    }

    println!("Part2: {}", longest);
}
