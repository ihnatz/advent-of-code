const T: bool = true;
const S: bool = false;

const ROW: &str= ".^^.^^^..^.^..^.^^.^^^^.^^.^^...^..^...^^^..^^...^..^^^^^^..^.^^^..^.^^^^.^^^.^...^^^.^^.^^^.^.^^.^.";
const N1: usize = 40;
const N2: usize = 400000;

fn next(current: &[bool]) -> Vec<bool> {
    current
        .iter()
        .enumerate()
        .map(|(idx, val)| {
            let l = if idx > 0 { current[idx - 1] } else { S };
            let c = *val;
            let r = if idx + 1 < current.len() {
                current[idx + 1]
            } else {
                S
            };

            match (l, c, r) {
                (T, T, S) => T,
                (S, T, T) => T,
                (T, S, S) => T,
                (S, S, T) => T,
                _ => S,
            }
        })
        .collect()
}

fn rounds(initial: &[bool], count: usize) -> usize {
    let mut current = initial.to_vec();
    let mut total = 0;
    for _ in 0..count {
        total += current.iter().filter(|&&x| x == S).count();
        current = next(&current);
    }
    total
}

fn main() {
    let initial: Vec<_> = ROW.bytes().map(|c| c == b'^').collect();
    println!("Part1: {}", rounds(&initial, N1));
    println!("Part2: {}", rounds(&initial, N2));
}

#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn test_next() {
        assert_eq!(next(&vec![S, S, T, T, S]), vec![S, T, T, T, T]);
        assert_eq!(
            next(&vec![S, T, T, S, T, S, T, T, T, T]),
            vec![T, T, T, S, S, S, T, S, S, T,]
        );
    }

    #[test]
    fn test_rounds() {
        let initial = vec![S,T,T,S,T,S,T,T,T,T,];
        assert_eq!(
            rounds(&initial, 10),
            38
        );
    }
}
