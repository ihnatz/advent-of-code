use std::collections::HashSet;
const H: usize = 103; const W: usize = 101;

fn main() {
    let input = include_str!("input.txt");
    let robots: Vec<_> = input.trim().lines().map(|line| {
        let pos: Vec<_> = line.split(|c: char| !c.is_ascii_digit() && c != '-')
            .filter(|s| !s.is_empty())
            .filter_map(|s| s.parse::<i32>().ok())
            .collect();
        ((pos[0], pos[1]), (pos[2], pos[3]))
    }).collect();

    let coords = robots.iter().map(|robot| {
        let (x, y) = robot.0;
        let (dx, dy) = robot.1;
        ((x + dx * 100).rem_euclid(W as i32), (y + dy * 100).rem_euclid(H as i32))
    }).collect::<Vec<_>>();

    let q1 = (0..W / 2, 0..H / 2);
    let q2 = (W / 2 + 1..W, 0..H / 2);
    let q3 = (0..W / 2, H / 2 + 1..H);
    let q4 = (W / 2 + 1..W, H / 2 + 1..H);

    let mut qs = (0, 0, 0, 0);
    for (x, y) in &coords {
        if q1.0.contains(&(*x as usize)) && q1.1.contains(&(*y as usize)) {
            qs.0 += 1;
        }
        if q2.0.contains(&(*x as usize)) && q2.1.contains(&(*y as usize)) {
            qs.1 += 1;
        }
        if q3.0.contains(&(*x as usize)) && q3.1.contains(&(*y as usize)) {
            qs.2 += 1;
        }
        if q4.0.contains(&(*x as usize)) && q4.1.contains(&(*y as usize)) {
            qs.3 += 1;
        }
    }

    let p1 = qs.0 * qs.1 * qs.2 * qs.3;

    for c in 0.. {
        let coords = robots.iter().map(|x| x.0).enumerate().map(|(idx, robot)| {
            let (mut x, mut y) = robot;
            let (dx, dy) = robots[idx].1;
            x = (x + dx * c).rem_euclid(W as i32);
            y = (y + dy * c).rem_euclid(H as i32);
            (x, y)
        }).collect::<Vec<_>>();


        let mut qs = (0, 0, 0, 0);
        for (x, y) in &coords {
            if q1.0.contains(&(*x as usize)) && q1.1.contains(&(*y as usize)) {
                qs.0 += 1;
            }
            if q2.0.contains(&(*x as usize)) && q2.1.contains(&(*y as usize)) {
                qs.1 += 1;
            }
            if q3.0.contains(&(*x as usize)) && q3.1.contains(&(*y as usize)) {
                qs.2 += 1;
            }
            if q4.0.contains(&(*x as usize)) && q4.1.contains(&(*y as usize)) {
                qs.3 += 1;
            }
        }

        let known_points = HashSet::<(i32, i32)>::from_iter(coords.iter().cloned());
        let symmetrial = coords
            .clone()
            .into_iter()
            .filter(|(x, y)| {
                q1.0.contains(&(*x as usize)) && q1.1.contains(&(*y as usize))
                    || q3.0.contains(&(*x as usize)) && q3.1.contains(&(*y as usize))
            })
            .filter(|(x, y)| known_points.contains(&(W as i32 - *x - 1, *y)))
            .collect::<HashSet<(i32, i32)>>();

        if symmetrial.len() > (robots.len() / 10) {
            println!("Part1: {:?}", p1);
            println!("Part2: {:?}", c);

            for y in 0..H {
                for x in 0..W {
                    if coords.contains(&(x as i32, y as i32)) {
                        print!("x");
                    } else {
                        print!(".");
                    }
                }
                println!();
            }
            break;
        }

    }
}
