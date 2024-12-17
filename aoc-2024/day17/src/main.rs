use regex::Regex;

fn to_combo(operand: i64, a: i64, b: i64, c: i64) -> i64 {
    match operand {
        (0..=3) => operand,
        4 => a,
        5 => b,
        6 => c,
        _ => unreachable!(),
    }
}

fn run(programm: &[i64], mut a: i64, mut b: i64, mut c: i64) -> Vec<usize> {
    let mut pointer = 0;
    let mut out = vec![];

    while pointer < programm.len() {
        let opcode = programm[pointer];
        let operand = programm[pointer + 1];

        let literal = operand;

        match opcode {
            0 => {
                a = a / 2_i64.pow(to_combo(operand, a, b, c) as u32);
                pointer += 2;
            }
            1 => {
                b = b ^ literal;
                pointer += 2;
            }
            2 => {
                b = to_combo(operand, a, b, c) % 8;
                pointer += 2;
            }
            3 => {
                if a != 0 {
                    pointer = literal as usize;
                } else {
                    pointer += 2;
                }
            }
            4 => {
                b = b ^ c;
                pointer += 2;
            }
            5 => {
                out.push((to_combo(operand, a, b, c) % 8) as usize);
                pointer += 2;
            }
            6 => {
                b = a / 2_i64.pow(to_combo(operand, a, b, c) as u32);
                pointer += 2;
            }
            7 => {
                c = a / 2_i64.pow(to_combo(operand, a, b, c) as u32);
                pointer += 2;
            }
            _ => unreachable!(),
        }
    }

    out
}


fn main() {
    let input = include_str!("input.txt");
    let (registers, programm) = input.trim().split_once("\n\n").unwrap();

    let re = Regex::new(r"-?\d+").unwrap();
    let registers: Vec<_> = re
        .find_iter(registers)
        .filter_map(|mat| mat.as_str().parse::<i64>().ok())
        .collect();
    let programm: Vec<_> = re
        .find_iter(programm)
        .filter_map(|mat| mat.as_str().parse::<i64>().ok())
        .collect();

    let [a, b, c] = registers.as_slice() else {
        unreachable!()
    };

    let p1 = run(&programm, *a, *b, *c).into_iter().map(|x| format!("{}", x)).collect::<Vec<String>>().join(",");
    println!("Part1: {}", p1);
}

#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn test_run() {
        assert_eq!(run(&vec![1, 7], 0, 29, 0), vec![]);
        assert_eq!(run(&vec![5, 0, 5, 1, 5, 4], 10, 0, 0), vec![0, 1, 2]);
        assert_eq!(
            run(&vec![0, 1, 5, 4, 3, 0], 2024, 0, 0),
            vec![4, 2, 5, 6, 7, 7, 7, 7, 3, 1, 0]
        );
    }
}
