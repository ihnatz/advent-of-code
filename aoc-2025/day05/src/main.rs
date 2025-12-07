fn main() {
    let input = include_str!("input.txt").trim();
    let (raw_ranges, raw_ids) = input.split_once("\r\n\r\n").unwrap();

    let mut ranges: Vec<(u64, u64)> = raw_ranges
        .lines()
        .map(|line| {
            let (start, end) = line.split_once('-').unwrap();
            (start.parse().unwrap(), end.parse().unwrap())
        })
        .collect();
    let ids: Vec<u64> = raw_ids
        .lines()
        .map(|line| line.trim().parse::<u64>().unwrap())
        .collect();

    let part1 = ids
        .into_iter()
        .filter(|id| ranges.iter().any(|(l, r)| id >= l && id <= r))
        .count();

    ranges.sort();
    let mut current = ranges[0];
    let mut combined = Vec::new();
    for range in ranges {
        if range == current {
            continue;
        }
        let (cl, cr) = current;
        let (nl, nr) = range;

        if nl >= cl && nl <= cr {
            let n = if cr > nr { cr } else { nr };
            current = (cl, n);
        } else {
            combined.push(current);
            current = range;
        }
    }
    combined.push(current);

    let part2 = combined.into_iter().map(|(l, r)| r - l + 1).sum::<u64>();

    println!("{:?}", part1);
    println!("{:?}", part2);
}
