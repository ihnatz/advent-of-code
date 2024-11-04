fn main() {
    let input = include_str!("input.txt");
    println!("Part1: {}", unwrap(input.trim()).len());
    println!("Part2: {}", unwrap_follow(input.trim()));
}

fn unwrap(input: &str) -> String {
    let mut unwrapping = 0;
    let mut subgroup = "";
    let mut unwrapped = Vec::new();
    let mut i = 0;
    loop {
        if unwrapping == 0 && i == input.len() {
            break;
        }

        let ch = if i < input.len() {
            input.bytes().nth(i).unwrap()
        } else {
            b' '
        };

        if unwrapping > 0 {
            for _ in 0..unwrapping {
                unwrapped.extend(subgroup.as_bytes());
            }
            unwrapping = 0;
        } else if ch == b'(' {
            i += 1;

            let j = consume(input, i, b'x');
            let next_chars = input[i..j].parse::<i32>().unwrap();
            i = j + 1;

            let j = consume(input, i, b')');
            unwrapping = input[i..j].parse::<i32>().unwrap();
            i = j + 1;

            subgroup = &input[i..i + next_chars as usize];
            i += next_chars as usize;
        } else {
            unwrapped.push(ch);
            i += 1;
        }
    }
    String::from_utf8(unwrapped).unwrap()
}

fn consume(input: &str, start: usize, stop: u8) -> usize {
    let mut j = start;
    while input.bytes().nth(j).unwrap() != stop {
        j += 1;
    }
    j
}

fn unwrap_follow(input: &str) -> i64 {
    let mut multipliers = vec![0 as i64; input.len()];
    let mut i = 0;

    while i < input.len() {
        let ch = input.bytes().nth(i).unwrap();

        if ch == b'(' {
            let start = i;
            i += 1;

            let j = consume(input, i, b'x');
            let next_chars = input[i..j].parse::<i64>().unwrap();
            i = j + 1;

            let j = consume(input, i, b')');
            let unwrapping = input[i..j].parse::<i64>().unwrap();
            i = j + 1;

            let finish = j;
            assert!(multipliers[start] == multipliers[finish]);

            for i in start..=finish {
                multipliers[i] = 0;
            }

            for i in 1..=next_chars {
                let new_idx = finish + i as usize;
                multipliers[new_idx] = multipliers[new_idx].max(1) * unwrapping;
            }
        } else {
            multipliers[i] = multipliers[i].max(1);
            i += 1;
        }
    }

    multipliers.into_iter().sum::<i64>()
}

#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn test_unwrap_with_extra() {
        assert_eq!(unwrap_follow("(3x3)XYZ"), 9);
        assert_eq!(unwrap_follow("X(8x2)(3x3)ABCY"), 20);
        assert_eq!(unwrap_follow("(27x12)(20x12)(13x14)(7x10)(1x12)A"), 241_920);
        assert_eq!(
            unwrap_follow("(25x3)(3x3)ABC(2x3)XY(5x2)PQRSTX(18x9)(3x2)TWO(5x7)SEVEN"),
            445
        );
    }

    #[test]
    fn test_basic_case() {
        assert_eq!(unwrap("(3x3)XYZ"), "XYZXYZXYZ");
        assert_eq!(unwrap("A(1x5)BC"), "ABBBBBC");
        assert_eq!(unwrap("A(2x2)BCD(2x2)EFG"), "ABCBCDEFEFG");
        assert_eq!(unwrap("(6x1)(1x3)A"), "(1x3)A");
        assert_eq!(unwrap("X(8x2)(3x3)ABCY"), "X(3x3)ABC(3x3)ABCY");
    }

    #[test]
    fn test_answers() {
        let input = include_str!("input.txt").trim();
        assert_eq!(unwrap(input).len(), 123_908);
        assert_eq!(unwrap_follow(input), 10_755_693_147);
    }
}
