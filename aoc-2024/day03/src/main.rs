use nom::{
    branch::alt,
    bytes::complete::tag,
    character::complete::{digit1, none_of},
    multi::many0,
    sequence::tuple,
    IResult,
};

#[derive(Debug, PartialEq, Eq, Clone)]
enum Instruction {
    Mul(i32, i32),
    Do(),
    Dont(),
}

fn parse_mul(input: &str) -> IResult<&str, Instruction> {
    let (input, (_, a, _, b, _)) = tuple((tag("mul("), digit1, tag(","), digit1, tag(")")))(input)?;
    let a = a.parse::<i32>().unwrap();
    let b = b.parse::<i32>().unwrap();
    Ok((input, Instruction::Mul(a, b)))
}

fn skip_until_ins(input: &str) -> IResult<&str, Vec<char>> {
    many0(none_of("md"))(input)
}

fn parse_do(input: &str) -> IResult<&str, Instruction> {
    let exist = tag("do()")(input)?;
    Ok((exist.0, Instruction::Do()))
}

fn parse_dont(input: &str) -> IResult<&str, Instruction> {
    let exist = tag("don't()")(input)?;
    Ok((exist.0, Instruction::Dont()))
}

fn parse(input: &str) -> IResult<&str, Vec<Instruction>> {
    let mut t = Vec::new();
    let mut current = input;

    while !current.is_empty() {
        let (new_current, _) = skip_until_ins(current)?;
        current = new_current;

        if current.is_empty() {
            break;
        }

        current = match alt((parse_do, parse_dont, parse_mul))(current) {
            Ok((new_current, ins)) => {
                t.push(ins);
                new_current
            }
            Err(_) => &current[1..],
        }
    }

    Ok(("", t))
}

fn exec(instructions: &[Instruction]) -> i32 {
    instructions
        .iter()
        .filter_map(|i| match i {
            Instruction::Mul(a, b) => Some(a * b),
            _ => None,
        })
        .sum()
}

fn exec_with_state(instructions: &[Instruction]) -> i32 {
    let mut m = 1;
    let mut t = 0;
    instructions.iter().for_each(|i| match i {
        Instruction::Mul(a, b) => t += m * a * b,
        Instruction::Do() => m = 1,
        Instruction::Dont() => m = 0,
    });
    t
}

fn main() {
    let input = include_str!("input.txt");
    let (_, instructions) = parse(&input).unwrap();
    println!("Part1: {}", exec(&instructions));
    println!("Part2: {}", exec_with_state(&instructions));
}

#[cfg(test)]
mod tests {
    use super::*;

    const MUL_COMMANDS: [Instruction; 4] = [
        Instruction::Mul(2, 4),
        Instruction::Mul(5, 5),
        Instruction::Mul(11, 8),
        Instruction::Mul(8, 5),
    ];
    const ALL_COMMANDS: [Instruction; 6] = [
        Instruction::Mul(2, 4),
        Instruction::Dont(),
        Instruction::Mul(5, 5),
        Instruction::Mul(11, 8),
        Instruction::Do(),
        Instruction::Mul(8, 5),
    ];

    #[test]
    fn test_parse() {
        let input = "xmul(2,4)%&mul[3,7]!@^do_not_mul(5,5)+mul(32,64]then(mul(11,8)mul(8,5))";
        let (_, values) = parse(&input).unwrap();
        assert!(values == MUL_COMMANDS);
    }

    #[test]
    fn test_parse_with_enables() {
        let input = "xmul(2,4)&mul[3,7]!^don't()_mul(5,5)+mul(32,64](mul(11,8)undo()?mul(8,5))";
        let (_, values) = parse(&input).unwrap();
        assert!(values == ALL_COMMANDS);
    }

    #[test]
    fn test_exec() {
        assert_eq!(exec(&MUL_COMMANDS), 161);
    }

    #[test]
    fn test_exec_with_state() {
        assert_eq!(exec_with_state(&ALL_COMMANDS), 48);
    }
}
