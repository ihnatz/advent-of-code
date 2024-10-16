use std::collections::HashSet;

const DIR_DX_DY: [(i32, i32); 4] = [(0, 1), (1, 0), (0, -1), (-1, 0)];

fn parse_steps(path: &str) -> Vec<(char, i32)> {
    path.trim()
        .split(", ")
        .map(|s| {
            (
                s.chars().nth(0).unwrap(),
                s.get(1..).unwrap().parse::<i32>().unwrap(),
            )
        })
        .collect()
}

fn follow_steps(steps: &[(char, i32)]) -> Vec<(i32, i32)> {
    let mut iterations: Vec<(i32, i32)> = Vec::new();
    let mut d: i32 = 0;
    let mut x: i32 = 0;
    let mut y: i32 = 0;

    for (dir, count) in steps.iter() {
        d = match dir {
            'L' => (d - 1).rem_euclid(4),
            'R' => (d + 1).rem_euclid(4),
            _ => panic!(),
        };
        let (dx, dy) = DIR_DX_DY[d as usize];

        for _ in 0..*count {
            x += dx;
            y += dy;
            iterations.push((x, y));
        }
    }

    iterations
}

fn follow(path: &str) -> i32 {
    let steps: Vec<(char, i32)> = parse_steps(path);
    let (x, y) = follow_steps(&steps).into_iter().last().unwrap();
    return x.abs() + y.abs();
}

fn get_start(path: &str) -> i32 {
    let steps: Vec<(char, i32)> = parse_steps(path);
    let mut visited: HashSet<(i32, i32)> = HashSet::new();

    let mut lx = 0;
    let mut ly = 0;

    for (x, y) in follow_steps(&steps) {
        if visited.contains(&(x, y)) {
            (lx, ly) = (x, y);
            break;
        }
        visited.insert((x, y));
    }

    return lx.abs() + ly.abs();
}

fn main() {
    let path = include_str!("input.txt");
    println!("Part1: {}", follow(&path));
    println!("Part2: {}", get_start(&path));
}

#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn test_follow_steps() {
        let mut steps = Vec::new();
        steps.push(('L', 1));
        steps.push(('R', 2));
        steps.push(('R', 3));
        let result = follow_steps(steps.as_slice());
        assert_eq!(
            result,
            vec![(-1, 0), (-1, 1), (-1, 2), (0, 2), (1, 2), (2, 2)]
        );
    }

    #[test]
    fn test_r2_l3() {
        assert_eq!(follow("R2, L3"), 5);
    }

    #[test]
    fn test_3_turns() {
        assert_eq!(follow("R2, R2, R2"), 2);
    }

    #[test]
    fn test_long() {
        assert_eq!(follow("R5, L5, R5, R3"), 12);
    }

    #[test]
    fn test_get_start() {
        assert_eq!(get_start("R8, R4, R4, R8"), 4);
    }
}
