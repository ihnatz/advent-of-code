fn main() {
    let input = include_str!("input.txt").trim();
    let lines = input.lines().skip(30).into_iter().collect::<Vec<_>>();
    let total = lines
        .into_iter()
        .filter(|line: &&str| {
            let (raw_box, raw_presents) = line.split_once(": ").unwrap();
            let sizes = raw_box.split_once("x").unwrap();
            let (w, h) = (
                sizes.0.parse::<i32>().unwrap(),
                sizes.1.parse::<i32>().unwrap(),
            );
            let presents = raw_presents
                .split(" ")
                .map(|r| r.parse::<i32>().unwrap())
                .collect::<Vec<_>>();
            w / 3 * h / 3 >= presents.iter().sum::<i32>()
        })
        .count();
    println!("Part1: {:?}", total);
}
