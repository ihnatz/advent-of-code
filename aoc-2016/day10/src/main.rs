use std::collections::HashMap;

use nom::{
    branch::alt, bytes::complete::tag, character::complete::digit1, sequence::tuple, IResult,
};

const COMPARING: (u32, u32) = (61, 17);

fn main() {
    go(include_str!("input.txt").trim());
}

#[derive(Debug, PartialEq)]
enum ActorType {
    Bot,
    Output,
}

#[derive(Debug, PartialEq)]
enum InputCommand {
    ValueGoes(u32, u32),
    BotGives(u32, ActorType, u32, ActorType, u32),
}

fn parse_bot_gives(input: &str) -> IResult<&str, InputCommand> {
    let (input, (_, bot_id, _, actor1, _, id1, _, actor2, _, id2)) = tuple((
        tag("bot "),
        digit1,
        tag(" gives low to "),
        alt((tag("output"), tag("bot"))),
        tag(" "),
        digit1,
        tag(" and high to "),
        alt((tag("output"), tag("bot"))),
        tag(" "),
        digit1,
    ))(input)?;

    let bot_id = bot_id.parse::<u32>().unwrap();
    let id1 = id1.parse::<u32>().unwrap();
    let id2 = id2.parse::<u32>().unwrap();
    let actor_type1 = if actor1 == "output" {
        ActorType::Output
    } else {
        ActorType::Bot
    };
    let actor_type2 = if actor2 == "output" {
        ActorType::Output
    } else {
        ActorType::Bot
    };

    Ok((
        input,
        InputCommand::BotGives(bot_id, actor_type1, id1, actor_type2, id2),
    ))
}

fn parse_values_goes(input: &str) -> IResult<&str, InputCommand> {
    let (input, (_, val, _, bot_id)) =
        tuple((tag("value "), digit1, tag(" goes to bot "), digit1))(input)?;
    let val = val.parse::<u32>().unwrap();
    let bot_id = bot_id.parse::<u32>().unwrap();
    Ok((input, InputCommand::ValueGoes(val, bot_id)))
}

fn parse(input: &str) -> IResult<&str, InputCommand> {
    alt((parse_values_goes, parse_bot_gives))(input)
}

fn go(input: &str) {
    let commands: Vec<_> = input
        .lines()
        .map(|line| {
            let (_, command) = parse(line).unwrap();
            command
        })
        .collect();

    let mut instructions: HashMap<u32, &InputCommand> = HashMap::new();
    for command in commands.iter() {
        if let InputCommand::BotGives(id, _, _, _, _) = command {
            instructions.insert(*id, command);
        }
    }

    let mut highs: HashMap<u32, u32> = HashMap::new();
    let mut lows: HashMap<u32, u32> = HashMap::new();
    let mut outputs: HashMap<u32, u32> = HashMap::new();

    for command in commands.iter() {
        if let InputCommand::ValueGoes(val, id) = command {
            if highs.contains_key(id) {
                let current = *highs.get(id).unwrap();
                if current < *val {
                    highs.insert(*id, *val);
                    lows.insert(*id, current);
                } else {
                    lows.insert(*id, *val);
                }
            } else {
                highs.insert(*id, *val);
            }
        }
    }

    loop {
        let active: Vec<u32> = highs
            .keys()
            .filter(|id| highs.contains_key(id) && lows.contains_key(id))
            .copied()
            .collect();

        if active.is_empty() {
            break;
        }

        for id in active.iter() {
            let command = instructions.get(id).unwrap();
            if let InputCommand::BotGives(_, tl, il, th, ih) = command {
                let low_val = lows[id];
                let high_val = highs[id];

                if (high_val, low_val) == COMPARING {
                    println!("Part1: {}", id);
                }

                match tl {
                    ActorType::Bot => {
                        let current = *highs.get(il).unwrap_or(&0);
                        if low_val > current {
                            highs.insert(*il, low_val);
                            if current > 0 {
                                lows.insert(*il, current);
                            }
                        } else {
                            lows.insert(*il, low_val);
                        }
                    }
                    ActorType::Output => {
                        outputs.insert(*il, low_val);
                    }
                }

                match th {
                    ActorType::Bot => {
                        let current = *highs.get(ih).unwrap_or(&0);
                        if high_val > current {
                            highs.insert(*ih, high_val);
                            if current > 0 {
                                lows.insert(*ih, current);
                            }
                        } else {
                            lows.insert(*ih, high_val);
                        }
                    }
                    ActorType::Output => {
                        outputs.insert(*ih, high_val);
                    }
                }

                highs.remove(id);
                lows.remove(id);
            }
        }
    }

    let total = outputs.get(&0).unwrap() * outputs.get(&1).unwrap() * outputs.get(&2).unwrap();
    println!("Part2: {total}");
}

#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn test_basic_case() {
        go(include_str!("sample.txt").trim());
    }

    #[test]
    fn test_parses_value_goes() {
        let input = "value 61 goes to bot 209";
        let (_, command) = parse(input).unwrap();
        assert_eq!(command, InputCommand::ValueGoes(61, 209));
    }

    #[test]
    fn test_parses_bot_gives() {
        let input = "bot 200 gives low to bot 40 and high to bot 141";
        let (_, command) = parse(input).unwrap();
        assert_eq!(
            command,
            InputCommand::BotGives(200, ActorType::Bot, 40, ActorType::Bot, 141)
        );

        let input = "bot 194 gives low to output 9 and high to bot 74";
        let (_, command) = parse(input).unwrap();
        assert_eq!(
            command,
            InputCommand::BotGives(194, ActorType::Output, 9, ActorType::Bot, 74)
        );
    }
}
