const KEYBOARD: [[i32; 3]; 3] = [[1, 2, 3], [4, 5, 6], [7, 8, 9]];

const KEYBOARD_EXTRA: [[i32; 5]; 5] = [
    [0, 0, 1, 0, 0],
    [0, 2, 3, 4, 0],
    [5, 6, 7, 8, 9],
    [0, 10, 11, 12, 0],
    [0, 0, 13, 0, 0],
];
struct Button {
    i: usize,
    j: usize,
}

impl Button {
    fn new(i: usize, j: usize) -> Self {
        Button { i, j }
    }

    fn to_key(&self) -> String {
        format!("{:X}", KEYBOARD[self.j as usize][self.i as usize])
    }

    fn to_key_extra(&self) -> String {
        format!("{:X}", KEYBOARD_EXTRA[self.j as usize][self.i as usize])
    }
}

fn follow(sequence: &str, start: &Button) -> Button {
    let mut i = start.i;
    let mut j = start.j;
    for ch in sequence.chars() {
        match ch {
            'L' => i = i.saturating_sub(1),
            'R' => i = (i + 1).min(2),
            'U' => j = j.saturating_sub(1),
            'D' => j = (j + 1).min(2),
            _ => panic!(),
        }
    }
    Button { i, j }
}

fn follow_extra(sequence: &str, start: &Button) -> Button {
    let mut i = start.i;
    let mut j = start.j;
    for ch in sequence.chars() {
        let mut ni = i;
        let mut nj = j;
        match ch {
            'L' => ni = i.saturating_sub(1),
            'R' => ni = (i + 1).min(4),
            'U' => nj = j.saturating_sub(1),
            'D' => nj = (j + 1).min(4),
            _ => panic!(),
        }
        if KEYBOARD_EXTRA[nj as usize][ni as usize] != 0 {
            (i, j) = (ni, nj);
        }
    }
    Button { i, j }
}

fn follow_instructions(
    start: Button,
    instructions: Vec<&str>,
    way: fn(&str, &Button) -> Button,
    present: fn(&Button) -> String,
) -> Vec<String> {
    instructions
        .iter()
        .scan(start, |current, &sequence| {
            *current = way(sequence, &current);
            Some(present(current))
        })
        .collect()
}

fn main() {
    let path = include_str!("input.txt");
    let part1 = follow_instructions(
        Button::new(1, 1),
        path.lines().collect(),
        follow,
        Button::to_key,
    );
    println!("Part1: {}", part1.join(""));
    let part2 = follow_instructions(
        Button::new(0, 2),
        path.lines().collect(),
        follow_extra,
        Button::to_key_extra,
    );
    println!("Part2: {}", part2.join(""));
}

#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn test_basic_follow() {
        let start = Button::new(1, 1);
        assert_eq!(follow("L", &start).to_key(), "4");
        assert_eq!(follow("LL", &start).to_key(), "4");
        assert_eq!(follow("ULL", &start).to_key(), "1");
        assert_eq!(follow("RRDDD", &Button::new(0, 0)).to_key(), "9");
    }

    #[test]
    fn test_extra_follow() {
        let start = Button::new(0, 2);
        assert_eq!(follow_extra("ULL", &start).to_key_extra(), "5");
        assert_eq!(follow_extra("RRDDD", &start).to_key_extra(), "D");
        assert_eq!(
            follow_extra("LURDL", &Button::new(2, 4)).to_key_extra(),
            "B"
        );
    }

    #[test]
    fn test_follow_all() {
        let instructions = vec!["ULL", "RRDDD", "LURDL", "UUUUD"];
        assert_eq!(
            follow_instructions(
                Button::new(1, 1),
                instructions.clone(),
                follow,
                Button::to_key
            ),
            ["1", "9", "8", "5"]
        );
        assert_eq!(
            follow_instructions(
                Button::new(0, 2),
                instructions.clone(),
                follow_extra,
                Button::to_key_extra
            ),
            ["5", "D", "B", "3"]
        );
    }
}
