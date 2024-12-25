fn is_overlap(lock: &[u8], key: &[u8], max_size: u8) -> bool {
    lock.iter().zip(key.iter()).any(|(l, k)| l + k > max_size)
}

fn main() {
    println!("Hello, world!");
    let input = include_str!("input.txt").trim();
    let mut keys: Vec<Vec<u8>> = vec![];
    let mut locks: Vec<Vec<u8>> = vec![];

    let max_size = input.split_once("\n\n").unwrap().0.split("\n").count() - 2;
    println!("{}", max_size);

    for grid in input.split("\n\n") {
        let grid = grid.lines().collect::<Vec<_>>();
        let is_lock = grid[0].bytes().all(|v| v == b'#');
        let is_key = grid[grid.len() - 1].bytes().all(|v| v == b'#');
        assert_ne!(is_lock, is_key);
        let mut pattern = vec![0; grid[0].len()];
        for (_, line) in grid.iter().enumerate() {
            for (x, cell) in line.bytes().enumerate() {
                if cell == b'#' {
                    pattern[x] += 1;
                }
            }
        }
        for i in 0..pattern.len() {
            pattern[i] -= 1;
        }
        if is_key {
            keys.push(pattern);
        } else {
            locks.push(pattern);
        }
    }
    let mut t = 0;
    for l in &locks {
        for k in &keys {
            if !is_overlap(&l, &k, max_size as u8) {
                println!("{:?} and {:?} fit", k, l);
                t += 1;
            } else {
                println!("{:?} and {:?} overlap", k, l);
            }
        }
    }
    println!("{:?}", t);
}
