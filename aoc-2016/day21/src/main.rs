#[derive(Debug)]
pub enum Instruction {
    ReversePositions(usize, usize),
    RotateBasedOnLetter(char),
    SwapPosition(usize, usize),
    MovePosition(usize, usize),
    SwapLetter(char, char),
    RotateLeft(usize),
    RotateRight(usize),
}

fn parse_line(line: &str) -> Option<Instruction> {
    let parts: Vec<&str> = line.split_whitespace().collect();

    match parts.as_slice() {
        ["reverse", "positions", start, "through", end] => Some(Instruction::ReversePositions(
            start.parse().ok()?,
            end.parse().ok()?,
        )),
        ["rotate", "based", "on", "position", "of", "letter", letter] => {
            Some(Instruction::RotateBasedOnLetter(letter.chars().next()?))
        }
        ["rotate", "left", steps, _] => Some(Instruction::RotateLeft(steps.parse().ok()?)),
        ["rotate", "right", steps, _] => Some(Instruction::RotateRight(steps.parse().ok()?)),
        ["swap", "position", pos1, "with", "position", pos2] => Some(Instruction::SwapPosition(
            pos1.parse().ok()?,
            pos2.parse().ok()?,
        )),
        ["swap", "letter", letter1, "with", "letter", letter2] => Some(Instruction::SwapLetter(
            letter1.chars().next()?,
            letter2.chars().next()?,
        )),
        ["move", "position", pos1, "to", "position", pos2] => Some(Instruction::MovePosition(
            pos1.parse().ok()?,
            pos2.parse().ok()?,
        )),
        _ => None,
    }
}

pub fn parse_instructions(input: &str) -> Vec<Instruction> {
    input
        .lines()
        .filter(|line| !line.trim().is_empty())
        .filter_map(parse_line)
        .collect()
}

fn index(vec: &[u8], letter: u8) -> usize {
    vec.iter().position(|&x| x == letter).unwrap()
}

fn apply(instruction: &Instruction, current: &[u8]) -> Vec<u8> {
    let mut cur = current.to_vec();
    match instruction {
        Instruction::SwapPosition(a, b) => {
            (cur[*a], cur[*b]) = (cur[*b], cur[*a]);
        }
        Instruction::SwapLetter(la, lb) => {
            let a = index(&cur, *la as u8);
            let b = index(&cur, *lb as u8);
            (cur[a], cur[b]) = (cur[b], cur[a]);
        }
        Instruction::ReversePositions(l, r) => {
            cur[*l..=*r].reverse();
        }
        Instruction::RotateLeft(i) => {
            cur.rotate_left(*i);
        }
        Instruction::RotateRight(i) => {
            cur.rotate_right(*i);
        }
        Instruction::MovePosition(l, r) => {
            let letter = cur[*l];
            cur.remove(*l);
            cur.insert(*r, letter);
        }
        Instruction::RotateBasedOnLetter(letter) => {
            let len = cur.len();
            let mut i = index(&cur, *letter as u8);
            if i >= 4 {
                i += 2;
            } else {
                i += 1;
            }
            cur.rotate_right(i % len);
        }
    }
    cur
}

fn inverse(instruction: &Instruction, current: &[u8]) -> Vec<u8> {
    let mut cur = current.to_owned();
    match instruction {
        Instruction::SwapPosition(a, b) => {
            (cur[*a], cur[*b]) = (cur[*b], cur[*a]);
        }
        Instruction::SwapLetter(la, lb) => {
            let a = index(&cur, *la as u8);
            let b = index(&cur, *lb as u8);
            (cur[a], cur[b]) = (cur[b], cur[a]);
        }
        Instruction::ReversePositions(l, r) => {
            cur[*l..=*r].reverse();
        }
        Instruction::RotateLeft(i) => {
            cur.rotate_right(*i);
        }
        Instruction::RotateRight(i) => {
            cur.rotate_left(*i);
        }
        Instruction::MovePosition(l, r) => {
            let letter = cur[*r];
            cur.remove(*r);
            cur.insert(*l, letter);
        }
        Instruction::RotateBasedOnLetter(letter) => {
            let i = index(&cur, *letter as u8);

            let mut steps = i / 2;
            if i % 2 == 1 || i == 0 {
                steps += 1;
            } else {
                steps += 5;
            }
            cur.rotate_left(steps);
        }
    }
    cur
}

fn main() {
    let input = include_str!("input.txt");
    let instructions = parse_instructions(input);

    println!("{:?}", forward("abcdefgh", &instructions));
    println!("{:?}", backward("fbgdceah", &instructions));
}

fn forward(input: &str, instructions: &[Instruction]) -> String {
    let mut cur: Vec<_> = input.bytes().collect();
    for instruction in instructions {
        cur = apply(instruction, &cur);
    }
    String::from_utf8(cur).unwrap()
}

fn backward(input: &str, instructions: &[Instruction]) -> String {
    let mut cur: Vec<_> = input.bytes().collect();
    for instruction in instructions.iter().rev() {
        cur = inverse(instruction, &cur);
    }
    String::from_utf8(cur).unwrap()
}

#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn test_parse_instructions() {
        let input = "
            reverse positions 1 through 6
            rotate based on position of letter a
            swap position 4 with position 1
            move position 5 to position 7
            rotate left 3 steps
            rotate right 0 steps
            swap letter d with letter c
        ";

        let instructions = parse_instructions(input);
        assert_eq!(instructions.len(), 7);
    }

    #[test]
    fn test_apply() {
        assert_eq!(
            apply(&Instruction::SwapPosition(0, 4), b"abcde".as_slice()),
            b"ebcda"
        );

        assert_eq!(
            apply(&Instruction::SwapLetter('d', 'b'), b"ebcda".as_slice()),
            b"edcba"
        );

        assert_eq!(
            apply(&Instruction::ReversePositions(0, 4), b"edcba".as_slice()),
            b"abcde"
        );

        assert_eq!(
            apply(&Instruction::RotateLeft(1), &b"abcde".as_slice()),
            b"bcdea"
        );

        assert_eq!(
            apply(&Instruction::MovePosition(1, 4), b"bcdea".as_slice()),
            b"bdeac"
        );

        assert_eq!(
            apply(&Instruction::MovePosition(3, 0), b"bdeac".as_slice()),
            b"abdec"
        );

        assert_eq!(
            apply(&Instruction::RotateBasedOnLetter('b'), b"abdec".as_slice()),
            b"ecabd"
        );

        assert_eq!(
            apply(&Instruction::RotateBasedOnLetter('d'), b"ecabd".as_slice()),
            b"decab"
        );
    }
}
