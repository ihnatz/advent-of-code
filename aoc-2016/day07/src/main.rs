use std::collections::BTreeSet;

use nom::{bytes::complete::tag, character::complete::alpha0, multi::many0, sequence::tuple};

struct IpV7 {
    hypernets: Vec<String>,
    sequences: Vec<String>,
}

impl IpV7 {
    fn new(input: &str) -> Self {
        let (rest, groups) =
            many0(tuple((alpha0::<&str, ()>, tag("["), alpha0, tag("]"))))(input).unwrap();
        let mut hypernets = Vec::new();
        let mut sequences = Vec::new();

        for (seg1, _, seg2, _) in groups {
            sequences.push(seg1.to_string());
            hypernets.push(seg2.to_string());
        }
        if !rest.is_empty() {
            sequences.push(rest.to_string());
        }

        IpV7 {
            hypernets,
            sequences,
        }
    }

    fn does_support_tls(&self) -> bool {
        self.sequences.iter().any(|s| has_abba(s)) && !self.hypernets.iter().any(|s| has_abba(s))
    }

    fn does_support_ssl(&self) -> bool {
        let mut seqence_triplets = BTreeSet::new();
        self.sequences
            .iter()
            .fold(&mut seqence_triplets, |acc, seq| {
                for triplet in triplets(seq) {
                    acc.insert(vec![triplet[1], triplet[0], triplet[1]]);
                }
                acc
            });

        let mut hypernets_triplets: BTreeSet<Vec<u8>> = BTreeSet::new();
        self.hypernets
            .iter()
            .fold(&mut hypernets_triplets, |acc, seq| {
                for triplet in triplets(seq) {
                    acc.insert(triplet);
                }
                acc
            });

        seqence_triplets
            .iter()
            .any(|seq| hypernets_triplets.contains(seq))
    }
}

fn has_abba(input: &str) -> bool {
    input
        .as_bytes()
        .windows(4)
        .any(|w| w[0] != w[1] && w[0] == w[3] && w[1] == w[2])
}

fn triplets(input: &str) -> BTreeSet<Vec<u8>> {
    let mut set = BTreeSet::new();
    for triplet in input.as_bytes().windows(3) {
        if triplet[0] == triplet[2] && triplet[0] != triplet[1] {
            set.insert(triplet.to_owned());
        }
    }
    set
}

fn main() {
    let input = include_str!("input.txt");
    let part1 = input
        .lines()
        .map(IpV7::new)
        .filter(|ip| ip.does_support_tls())
        .count();

    let part2 = input
        .lines()
        .map(IpV7::new)
        .filter(|ip| ip.does_support_ssl())
        .count();

    println!("Part1: {}", part1);
    println!("Part2: {}", part2);
}

#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn test_parses_string() {
        let input = "ioxxoj[asdfgh]zxcvbn";
        let ip = IpV7::new(input);

        assert_eq!(ip.hypernets, vec!["asdfgh"]);
        assert_eq!(ip.sequences, vec!["ioxxoj", "zxcvbn"]);
    }

    #[test]
    fn test_parses_string_with_multiple_groups() {
        let input = "ioxxoj[asdfgh]zxcvbn[iddqd]abba";
        let ip = IpV7::new(input);

        assert_eq!(ip.hypernets, vec!["asdfgh", "iddqd"]);
        assert_eq!(ip.sequences, vec!["ioxxoj", "zxcvbn", "abba"]);
    }

    #[test]
    fn test_check_for_has_abba() {
        assert!(has_abba("abba"));
        assert!(has_abba("zabbaz"));
        assert!(!has_abba("zabdbaz"));
        assert!(has_abba("ioxxoj"));
        assert!(!has_abba("zxcvbn"));
        assert!(!has_abba("aaaa"));
    }

    #[test]
    fn test_get_triplets() {
        let mut actual = triplets("xzazbzxyx").into_iter().collect::<Vec<_>>();
        actual.sort();

        let mut expected = vec!["zaz", "zbz", "xyx"]
            .iter()
            .map(|s| s.as_bytes())
            .collect::<Vec<_>>();
        expected.sort();

        assert_eq!(actual, expected);
    }

    #[test]
    fn test_does_support_ssl() {
        assert!(IpV7::new("zazbz[bzb]cdb").does_support_ssl());
        assert!(IpV7::new("aaa[kek]eke").does_support_ssl());
        assert!(!IpV7::new("xyx[xyx]xyx").does_support_ssl());
        assert!(IpV7::new("aba[bab]xyz").does_support_ssl());
    }
}
