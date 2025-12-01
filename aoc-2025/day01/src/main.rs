fn main() {
    let input = include_str!("input.txt");
    let content = input
        .lines()
        .map(|line| parse_rotation(line))
        .collect::<Vec<i32>>();

    let mut t = 0;
    let mut current = 50;
    for r in &content {
        current = (current + r + 100) % 100;
        if current == 0 {
            t += 1;
        }
    }
    println!("Part1: {:?}", t);

    let mut t = 0;
    let mut current = 50;
    for r in &content {
        let sign = if *r > 0 { 1 } else { -1 };
        for _i in 0..r.abs() {
            current += sign * 1;
            if current % 100 == 0 {
                t += 1
            }
            current = current % 100;
        }
    }
    println!("Part2: {:?}", t);
}

fn parse_rotation(s: &str) -> i32 {
    let num: i32 = s[1..].parse().unwrap();
    if s.chars().nth(0).unwrap() == 'L' {
        return num * -1;
    }
    num
}
