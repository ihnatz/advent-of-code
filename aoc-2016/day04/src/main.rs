use std::{collections::HashMap, ops::AddAssign};

use once_cell::sync::Lazy;
use regex::Regex;

static CHECKSUM_RE: Lazy<Regex> = Lazy::new(|| Regex::new(r"\[([a-z]+)\]$").unwrap());
static ID_RE: Lazy<Regex> = Lazy::new(|| Regex::new(r"\-(\d+)\[").unwrap());
static NAME_RE: Lazy<Regex> = Lazy::new(|| Regex::new(r"^([a-z\-]+)\-").unwrap());

struct Room<'a> {
    checksum: &'a str,
    name: &'a str,
    id: i32,
}

impl<'a> Room<'a> {
    fn from_str(encrypted_name: &'a str) -> Self {
        let checksum = CHECKSUM_RE
            .captures(encrypted_name)
            .unwrap()
            .get(1)
            .unwrap()
            .as_str();
        let id = ID_RE
            .captures(encrypted_name)
            .unwrap()
            .get(1)
            .unwrap()
            .as_str()
            .parse::<i32>()
            .unwrap();
        let name = NAME_RE
            .captures(encrypted_name)
            .unwrap()
            .get(1)
            .unwrap()
            .as_str();

        Room { checksum, name, id }
    }

    fn decrypted(&self) -> String {
        let add = (self.id % 26) as u8;
        self.name
            .chars()
            .into_iter()
            .map(|ch| {
                if ch == '-' {
                    ' '
                } else {
                    (((ch as u8 - b'a').saturating_add(add) % 26) + b'a') as char
                }
            })
            .collect()
    }

    fn is_valid(&self) -> bool {
        let mut freq: HashMap<char, i32> = HashMap::new();
        for ch in self.name.chars() {
            if ch == '-' {
                continue;
            }
            *freq.entry(ch).or_insert(0) += 1;
        }
        let mut items: Vec<_> = freq.into_iter().collect();
        items.sort_by(|a, b| b.1.cmp(&a.1));

        let mut result = "".to_string();
        let mut current_count = -1;
        let mut current_group = "".to_string();

        for (ch, count) in items {
            if count != current_count {
                let mut g: Vec<char> = current_group.chars().collect();
                g.sort();
                result.push_str(&g.into_iter().collect::<String>());
                current_group = ch.to_string();
                current_count = count;
            } else {
                current_group.push(ch);
            }
        }

        let mut g: Vec<char> = current_group.chars().collect();
        g.sort();
        result.push_str(&g.into_iter().collect::<String>());

        &result[0..5] == self.checksum
    }
}

fn main() {
    let input = include_str!("input.txt");
    let rooms: Vec<Room> = input.lines().map(|line| Room::from_str(line)).collect();
    let part1 = rooms
        .iter()
        .filter(|room| room.is_valid())
        .map(|room| room.id)
        .sum::<i32>();
    println!("Part1: {part1}");
    let part2 = rooms
        .iter()
        .find(|room| room.decrypted() == "northpole object storage")
        .unwrap()
        .id;
    println!("Part2: {part2}");
}

#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn test_parses_string() {
        let input = "aaaaa-bbb-z-y-x-123[abxyz]";
        let room = Room::from_str(input);

        assert_eq!(room.name, "aaaaa-bbb-z-y-x");
        assert_eq!(room.checksum, "abxyz");
        assert_eq!(room.id, 123)
    }

    #[test]
    fn test_check_valid() {
        assert!(Room::from_str("aaaaa-bbb-z-y-x-123[abxyz]").is_valid());
        assert!(Room::from_str("a-b-c-d-e-f-g-h-987[abcde]").is_valid());
        assert!(Room::from_str("not-a-real-room-404[oarel]").is_valid());
        assert!(!Room::from_str("totally-real-room-200[decoy]").is_valid());
    }

    #[test]
    fn test_decrypt_name() {
        assert_eq!(
            Room::from_str("qzmt-zixmtkozy-ivhz-343[abxyz]").decrypted(),
            "very encrypted name"
        );
    }
}
