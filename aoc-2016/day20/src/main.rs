use std::collections::VecDeque;

const LAST: u32 = 4294967295;

fn main() {
    let input = include_str!("input.txt");
    let mut pairs: Vec<_> = input.lines().map(|line| {
        let values: Vec<_> = line.split("-").collect();
        let [l, r] = values.as_slice() else { panic!() };
        let l = l.parse::<u32>();
        let r = r.parse::<u32>();
        (l.unwrap(), r.unwrap())
    }).collect();
    pairs.sort_by_key(|(l, _)| *l);

    let mut combined = VecDeque::new();
    combined.push_front(*pairs.first().unwrap());

    for (il, ir) in pairs[1..].iter() {
        let (cl, cr) = combined.pop_back().unwrap();
        let (il, ir) = (*il, *ir);

        if cr >= il || il - cr == 1 {
            let l = cl;
            let r = ir.max(cr);
            combined.push_back((l, r));
        } else {
            combined.push_back((cl, cr));
            combined.push_back((il, ir));
        }
    }

    println!("Part1: {:?}", combined[0].1 + 1);

    let mut total = LAST;
    for (l, r) in combined.iter() {
        total -= r - l + 1;
    }
    println!("Part2: {:?}", total + 1);
}
