use nom::{
    branch::alt, bytes::complete::tag, character::complete::digit1, sequence::tuple, IResult,
};
use std::fmt;

const WIDTH: usize = 50;
const HEIGHT: usize = 6;

struct Screen {
    buf: Vec<bool>,
}

impl Screen {
    fn new() -> Self {
        let buf = vec![false; WIDTH * HEIGHT];
        Screen { buf }
    }

    fn get(&self, i: usize, j: usize) -> bool {
        self.buf[(j % HEIGHT) * WIDTH + (i % WIDTH)]
    }

    fn get_mut(&mut self, i: usize, j: usize) -> &mut bool {
        &mut self.buf[(j % HEIGHT) * WIDTH + (i % WIDTH)]
    }

    fn rect(&mut self, cols: usize, rows: usize) {
        for j in 0..rows {
            for i in 0..cols {
                *self.get_mut(i, j) = true;
            }
        }
    }

    fn rotate_column(&mut self, x: usize, by: usize) {
        let mut column: Vec<_> = (0..HEIGHT).map(|j| self.get(x, j)).collect();
        column.rotate_right(by % HEIGHT);

        for j in 0..HEIGHT {
            *(self.get_mut(x, j)) = column[j];
        }
    }

    fn rotate_row(&mut self, y: usize, by: usize) {
        let mut column: Vec<_> = (0..WIDTH).map(|i| self.get(i, y)).collect();
        column.rotate_right(by % WIDTH);

        for i in 0..WIDTH {
            *(self.get_mut(i, y)) = column[i];
        }
    }
}

impl fmt::Display for Screen {
    fn fmt(&self, f: &mut fmt::Formatter) -> fmt::Result {
        for (i, &val) in self.buf.iter().enumerate() {
            if i % WIDTH == 0 {
                writeln!(f)?;
            }
            let ch = if val { "#" } else { "." };
            write!(f, "{ch}")?;
        }
        writeln!(f)
    }
}

#[derive(Debug)]
enum Command {
    Rect(usize, usize),
    RotateColumn(usize, usize),
    RotateRow(usize, usize),
}

fn parse_rect(input: &str) -> IResult<&str, Command> {
    let (input, (_, row, _, col)) = tuple((tag("rect "), digit1, tag("x"), digit1))(input)?;
    let row = row.parse::<usize>().unwrap();
    let col = col.parse::<usize>().unwrap();
    Ok((input, Command::Rect(row, col)))
}

fn parse_rotate_row(input: &str) -> IResult<&str, Command> {
    let (input, (_, y, _, by)) = tuple((tag("rotate row y="), digit1, tag(" by "), digit1))(input)?;
    let y = y.parse::<usize>().unwrap();
    let by = by.parse::<usize>().unwrap();
    Ok((input, Command::RotateRow(y, by)))
}

fn parse_rotate_column(input: &str) -> IResult<&str, Command> {
    let (input, (_, x, _, by)) =
        tuple((tag("rotate column x="), digit1, tag(" by "), digit1))(input)?;
    let x = x.parse::<usize>().unwrap();
    let by = by.parse::<usize>().unwrap();
    Ok((input, Command::RotateColumn(x, by)))
}

fn parse(input: &str) -> IResult<&str, Command> {
    alt((parse_rect, parse_rotate_row, parse_rotate_column))(input)
}

fn main() {
    let input = include_str!("input.txt");

    let mut screen = Screen::new();
    for line in input.lines() {
        match parse(line) {
            Ok((_, Command::Rect(x, y))) => screen.rect(x, y),
            Ok((_, Command::RotateColumn(x, by))) => screen.rotate_column(x, by),
            Ok((_, Command::RotateRow(y, by))) => screen.rotate_row(y, by),
            _ => panic!(),
        }
    }

    let part1 = screen.buf.iter().filter(|v| **v).count();
    println!("Part1: {}", part1);
    println!("Part2: {}", screen);
}
