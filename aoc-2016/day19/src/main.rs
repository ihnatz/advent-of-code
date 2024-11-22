const N: u64 = 3014387;

fn log(n: u64, p: u32) -> u64 {
    ((n as f32).ln() / (p as f32).ln()) as u64
}


fn main() {
    let power = log(N, 2);
    let closest = (2 as u64).checked_pow(power as u32).unwrap();
    let position = 2 * (N - closest) + 1;
    println!("Part1: {}", position);

    let power = log(N - 1, 3);
    let closest = (3 as u64).checked_pow(power as u32).unwrap();
    let position = if N <= 2 * closest {
        N - closest
    } else {
        N - closest + N - 2 * closest
    };
    println!("Part2: {}", position);
}
