const ALPHA_SIZE: usize = 26;

fn caclulate_frequency(input: &str) -> Vec<u8> {
    let mut buff = vec![0 as u8; ALPHA_SIZE * 8];
    input.lines().for_each(|line| {
        for (idx, ch) in line.as_bytes().iter().enumerate() {
            let alpha_id = (*ch - b'a') as usize;
            let bufferd_idx = idx * ALPHA_SIZE + alpha_id;
            buff[bufferd_idx] += 1;
        }
    });
    buff
}

fn part1(input: &str) -> String {
    let buff = caclulate_frequency(input);

    let result: Vec<_> = buff
        .chunks(ALPHA_SIZE)
        .map(|chunk| {
            chunk
                .iter()
                .enumerate()
                .max_by_key(|(_alpha_idx, freq)| **freq)
                .take()
                .unwrap()
                .0 as u8
                + b'a'
        })
        .collect();

    String::from_utf8(result).unwrap()
}

fn part2(input: &str) -> String {
    let buff = caclulate_frequency(input);

    let result: Vec<_> = buff
        .chunks(ALPHA_SIZE)
        .map(|chunk| {
            chunk
                .iter()
                .enumerate()
                .min_by_key(
                    |(_alpha_idx, freq)| {
                        if **freq == 0 {
                            u8::MAX
                        } else {
                            **freq
                        }
                    },
                )
                .take()
                .unwrap()
                .0 as u8
                + b'a'
        })
        .collect();

    String::from_utf8(result).unwrap()
}

fn main() {
    let input = include_str!("input.txt");
    println!("Part1: {}", part1(input));
    println!("Part2: {}", part2(input));
}
