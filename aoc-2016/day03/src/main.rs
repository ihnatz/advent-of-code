struct Triangle {
    sides: (i32, i32, i32),
}

impl Triangle {
    fn new(arr: &[i32]) -> Self {
        Triangle {
            sides: (arr[0], arr[1], arr[2]),
        }
    }

    fn is_valid(&self) -> bool {
        self.sides.0 + self.sides.1 > self.sides.2
            && self.sides.0 + self.sides.2 > self.sides.1
            && self.sides.1 + self.sides.2 > self.sides.0
    }
}

fn count_valid_horizontal(input: &str) -> usize {
    input
        .lines()
        .map(|line| {
            let sides: Vec<i32> = line
                .trim()
                .split_whitespace()
                .map(|v| v.parse::<i32>().unwrap())
                .collect();
            Triangle::new(sides.as_slice())
        })
        .filter(|t| t.is_valid())
        .count()
}

fn count_valid_vertical(input: &str) -> usize {
    let numbers: Vec<Vec<_>> = input
        .lines()
        .map(|line| {
            line.trim()
                .split_whitespace()
                .map(|v| v.parse::<i32>().unwrap())
                .collect()
        })
        .collect();
    numbers
        .chunks(3)
        .flat_map(|chunk| (0..=2).map(|v| Triangle::new(&[chunk[0][v], chunk[1][v], chunk[2][v]])))
        .filter(|t| t.is_valid())
        .count()
}

fn main() {
    let input = include_str!("input.txt");
    println!("Part1: {}", count_valid_horizontal(input));
    println!("Part2: {}", count_valid_vertical(input));
}

#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn test_is_valid() {
        assert!(!Triangle { sides: (5, 10, 25) }.is_valid());
        assert!(Triangle { sides: (5, 6, 7) }.is_valid());
    }
}
