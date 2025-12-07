use std::collections::HashSet;

type Coord = (usize, usize);

const DS: [i32; 3] = [-1, 0, 1];

fn safe_add(p: Coord, dx: i32, dy: i32) -> Option<Coord> {
    let (x, y) = p;
    let casted_nx = x as i32 + dx;
    let casted_ny = y as i32 + dy;
    if casted_nx < 0 || casted_ny < 0 {
        return None;
    }
    Some((casted_nx as usize, casted_ny as usize))
}

fn neighbors(paper: &HashSet<Coord>, current: Coord) -> usize {
    let mut around = 0;
    for dr in DS {
        for dc in DS {
            if dr == 0 && dc == 0 {
                continue;
            };
            if let Some((nr, nc)) = safe_add(current, dr, dc) {
                if paper.contains(&(nr, nc)) {
                    around += 1
                }
            }
        }
    }
    around
}

fn next_generation(paper: &HashSet<Coord>) -> HashSet<Coord> {
    paper
        .iter()
        .filter(|p| neighbors(&paper, **p) >= 4)
        .copied()
        .collect()
}

fn main() {
    let input = include_str!("input.txt");
    let mut paper: HashSet<Coord> = HashSet::new();

    for (row, line) in input.lines().enumerate() {
        for (col, val) in line.chars().enumerate() {
            if val == '@' {
                paper.insert((row, col));
            }
        }
    }

    let mut current = paper.clone();
    loop {
        let new_generation = next_generation(&current);
        if new_generation.len() == current.len() {
            break;
        }
        current = new_generation;
    }

    let part1 = paper.iter().filter(|p| neighbors(&paper, **p) < 4).count();
    let part2 = paper.len() - current.len();

    println!("{:?}", part1);
    println!("{:?}", part2);
}
