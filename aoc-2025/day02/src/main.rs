fn main() {
    let input = include_str!("input.txt");
    let pairs: Vec<_> = input
        .trim()
        .split(',')
        .map(|spair| {
            let pair = spair.split('-').collect::<Vec<&str>>();
            let l = pair[0].parse::<u64>().expect("can't parse");
            let r = pair[1].parse::<u64>().expect("can't parse");
            (l, r)
        })
        .collect();

    let mut t1 = 0;
    let mut t2 = 0;
    for pair in &pairs {
        t1 += run_pair(pair.0, pair.1);
        t2 += run_pair_ext(pair.0, pair.1);
    }
    println!("Part1: {:?}", t1);
    println!("Part2: {:?}", t2);
}

fn run_pair(left: u64, right: u64) -> u64 {
    let mut t = 0;
    let lstr = left.to_string();
    let half = if lstr.len() % 2 == 0 {
        lstr[0..lstr.len() / 2].to_string()
    } else {
        (10_u64.pow((lstr.len() / 2) as u32)).to_string()
    };

    let mut current = half.parse::<u64>().expect("can't parse half");
    loop {
        let combined = format!("{}{}", current, current).parse::<u64>().unwrap();
        if combined < left {
            current += 1;
            continue;
        }
        if (left..=right).contains(&combined) {
            t += combined;
            current += 1;
        } else {
            break;
        }
    }
    t
}

fn run_pair_ext(left: u64, right: u64) -> u64 {
    let mut t = 0_u64;
    for v in left..=right {
        if is_valid(v) {
            t += v;
        }
    }
    t
}

fn is_valid(num: u64) -> bool {
    let num_str = num.to_string();
    for i in 1..=num_str.len() / 2 {
        let subs = num_str[0..i].to_string();
        if num_str.len() % subs.len() != 0 {
            continue;
        }
        let times = num_str.len() / subs.len();
        if subs.repeat(times) == num_str {
            return true;
        }
    }
    false
}
