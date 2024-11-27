use nom::{
    branch::alt,
    bytes::complete::tag,
    character::complete::digit1,
    character::complete::{anychar, char, multispace0},
    combinator::{map, map_res, opt, recognize, verify},
    sequence::tuple,
    sequence::{preceded, separated_pair},
    IResult,
};

#[derive(Debug, PartialEq)]
pub enum Value {
    Register(u8),
    Integer(i32),
}

#[derive(Debug, PartialEq)]
pub enum Instruction {
    Copy(Value, Value),
    Increment(Value),
    Decrement(Value),
    Output(Value),
    JumpNotZero(Value, Value),
}

fn parse_register(input: &str) -> IResult<&str, u8> {
    map(verify(anychar, |c: &char| c.is_ascii_lowercase()), |c| {
        (c as u8) - b'a'
    })(input)
}

fn parse_integer(input: &str) -> IResult<&str, i32> {
    map_res(recognize(tuple((opt(char('-')), digit1))), |s: &str| {
        s.parse::<i32>()
    })(input)
}

fn parse_register_value(input: &str) -> IResult<&str, Value> {
    map(parse_register, Value::Register)(input)
}

fn parse_value(input: &str) -> IResult<&str, Value> {
    alt((
        map(parse_register, Value::Register),
        map(parse_integer, Value::Integer),
    ))(input)
}

fn parse_copy(input: &str) -> IResult<&str, Instruction> {
    map(
        preceded(
            tuple((tag("cpy"), multispace0)),
            separated_pair(parse_value, multispace0, parse_register_value),
        ),
        |(src, dest)| Instruction::Copy(src, dest),
    )(input)
}

fn parse_out(input: &str) -> IResult<&str, Instruction> {
    map(
        preceded(tuple((tag("out"), multispace0)), parse_register_value),
        Instruction::Output,
    )(input)
}

fn parse_increment(input: &str) -> IResult<&str, Instruction> {
    map(
        preceded(tuple((tag("inc"), multispace0)), parse_register_value),
        Instruction::Increment,
    )(input)
}

fn parse_decrement(input: &str) -> IResult<&str, Instruction> {
    map(
        preceded(tuple((tag("dec"), multispace0)), parse_register_value),
        Instruction::Decrement,
    )(input)
}

fn parse_jump_not_zero(input: &str) -> IResult<&str, Instruction> {
    map(
        preceded(
            tuple((tag("jnz"), multispace0)),
            separated_pair(parse_value, multispace0, parse_value),
        ),
        |(cond, offset)| Instruction::JumpNotZero(cond, offset),
    )(input)
}

pub fn parse_instruction(input: &str) -> IResult<&str, Instruction> {
    preceded(
        multispace0,
        alt((
            parse_copy,
            parse_increment,
            parse_decrement,
            parse_out,
            parse_jump_not_zero,
        )),
    )(input)
}

fn run(registers: &mut [i32; 4], instructions: &[Instruction]) -> Vec<i32> {
    let mut ptr = 0;
    let mut output = Vec::with_capacity(100);

    loop {
        if output.len() == 100 {
            return output;
        }

        let current_instruction = instructions.get(ptr).unwrap();
        match current_instruction {
            Instruction::Copy(from, Value::Register(to)) => {
                let value = match from {
                    Value::Integer(val) => *val,
                    Value::Register(i) => registers[*i as usize],
                };
                registers[*to as usize] = value;
                ptr += 1;
            }
            Instruction::Increment(Value::Register(to)) => {
                registers[*to as usize] += 1;
                ptr += 1;
            }
            Instruction::Decrement(Value::Register(to)) => {
                registers[*to as usize] -= 1;
                ptr += 1;
            }
            Instruction::Output(Value::Register(to)) => {
                output.push(registers[*to as usize]);
                ptr += 1;
            }
            Instruction::JumpNotZero(from, Value::Integer(away)) => {
                let value = match from {
                    Value::Integer(val) => *val,
                    Value::Register(i) => registers[*i as usize],
                };
                if value != 0 {
                    ptr = (ptr as i32 + *away as i32) as usize;
                } else {
                    ptr += 1;
                }
            }
            _ => (),
        }
    }
}

fn main() {
    let instructions: Vec<_> = include_str!("input.txt")
        .trim()
        .lines()
        .map(|line| parse_instruction(line).unwrap().1)
        .collect();

    let expected: Vec<i32> = [0, 1].iter().cycle().take(100).cloned().collect();
    for i in 1.. {
        let actual = run(&mut [i, 0, 0, 0], &instructions);
        if actual == expected {
            println!("Part1: {:?}", i);
            break;
        }
    }
}

#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn test_parse_cpy_digit() {
        assert_eq!(
            parse_instruction("cpy 41 a"),
            Ok((
                "",
                Instruction::Copy(Value::Integer(41), Value::Register(0))
            ))
        );
    }

    #[test]
    fn test_parse_cpy_register() {
        assert_eq!(
            parse_instruction("cpy a b"),
            Ok((
                "",
                Instruction::Copy(Value::Register(0), Value::Register(1))
            ))
        );
    }

    #[test]
    fn test_parse_inc() {
        assert_eq!(
            parse_instruction("inc c"),
            Ok(("", Instruction::Increment(Value::Register(2))))
        );
    }

    #[test]
    fn test_parse_dec() {
        assert_eq!(
            parse_instruction("dec d"),
            Ok(("", Instruction::Decrement(Value::Register(3))))
        );
    }

    #[test]
    fn test_parse_jnz() {
        assert_eq!(
            parse_instruction("jnz b -2"),
            Ok((
                "",
                Instruction::JumpNotZero(Value::Register(1), Value::Integer(-2))
            ))
        );
    }
}
