use std::{collections::HashSet, sync::mpsc, thread};
use md5::{Digest, Md5};

const SALT: &str = "cuanljph";
const WORKERS: usize = 8;
const LIMIT: usize = 64;

const HEX_CHARS: &[u8] = b"0123456789abcdef";
#[inline]
fn to_hex_string(bytes: &[u8]) -> String {
    let mut result = String::with_capacity(32);
    for &byte in bytes {
        result.push(HEX_CHARS[(byte >> 4) as usize] as char);
        result.push(HEX_CHARS[(byte & 0xf) as usize] as char);
    }
    result
}

#[inline]
fn md5(candidate: &str) -> String {
    let mut hasher = Md5::new();
    hasher.update(candidate);
    to_hex_string(&hasher.finalize())
}

#[inline]
fn stretching_md5(candidate: &str) -> String {
    (0..=2016).fold(candidate.to_string(), |acc, _| {
        md5(&acc)
    }).to_string()
}

fn triplet(input: &str) -> Option<u8> {
    input
        .as_bytes()
        .windows(3)
        .find(|&window| window.iter().all(|&b| b == window[0]))
        .map(|window| window[0])
}

fn quintet(input: &str) -> Option<u8> {
    input
        .as_bytes()
        .windows(5)
        .find(|&window| window.iter().all(|&b| b == window[0]))
        .map(|window| window[0])
}


fn main() {
    println!("Part1: {}", run(md5));
    println!("Part2: {}", run(stretching_md5));
}

fn run(f: fn(&str) -> String) -> usize {
    let (tx, rx) = mpsc::channel();

    for i in 0..WORKERS {
        let newtx = tx.clone();

        thread::spawn(move || {
            let mut current = i;
            loop {
                let input = format!("{}{}", SALT, current);
                let hash = f(&input);
                let t = triplet(&hash);
                let q = quintet(&hash);
                if t.is_some() || q.is_some() {
                    newtx.send((current, t, q)).unwrap_or_default();
                }
                current += WORKERS;
            }
        });
    }

    let mut collected_triplets = HashSet::new();
    let mut collected_quintets= HashSet::new();

    while let Ok((i, ot, oq)) = rx.recv() {
        if let Some(q) = oq {
            collected_quintets.insert((i, q));
            if collected_quintets.len() >= LIMIT {
                break;
            }
        }
        if let Some(t) = ot {
            collected_triplets.insert((i, t));
        }
    }

    let mut triplets: Vec<_> = collected_triplets.iter().collect();
    triplets.sort_by_key(|(i, _)| *i);
    let mut found = HashSet::new();

    for (idx, val) in triplets.into_iter() {
        for potential in (idx + 1)..=(idx + 1000) {
            if collected_quintets.contains(&(potential, *val)) {
                found.insert(idx);
                if found.len() == 64 {
                    return *idx;
                }
            }
        }
    }

    return 0;
}


#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn test_validate_hash_calculation() {
        assert_eq!(
            md5("abc18"),
            "0034e0923cc38887a57bd7b1d4f953df"
        );
    }

    #[test]
    fn test_validate_stretched_md5() {
        assert_eq!(
            stretching_md5("abc0"),
            "a107ff634856bb300138cac6568c0f24"
        );
    }

    #[test]
    fn test_triplets_finds_triplet() {
        assert_eq!(triplet("abc111def333gfg"), Some('1' as u8));
        assert_eq!(triplet("a1b2c3d4e5f6g7h"), None);
    }

    #[test]
    fn test_triplets_finds_quintet() {
        assert_eq!(quintet("abc11111f333gfg"), Some('1' as u8));
        assert_eq!(quintet("abc111def333gfg"), None);
        assert_eq!(quintet("a1b2c3d4e5f6g7h"), None);
    }
}