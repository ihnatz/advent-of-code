fn main() {
    let input = include_str!("input.txt");
    let mut content: Vec<String> = input.lines().map(|line| line.to_string()).collect();
    let operators = content.pop().unwrap();

    let max_line = content.iter().map(|line| line.len()).max().unwrap();
    for line in &mut content {
        let diff = max_line - line.len();
        if diff > 0 {
            line.push_str(&" ".repeat(diff));
        }
    }

    let mut current_start = 0;
    let mut total1 = 0;
    let mut total2 = 0;
    for (i, ch) in operators.chars().into_iter().enumerate() {
        if i == 0 {
            continue;
        }

        if ch != ' ' {
            let affected = content
                .iter()
                .map(|line| &line[current_start..i - 1])
                .collect::<Vec<_>>();
            total1 += run1(&affected, operators.chars().nth(current_start).unwrap());
            total2 += run(&affected, operators.chars().nth(current_start).unwrap());
            current_start = i;
        }

        if i == operators.len() - 1 {
            let affected = content
                .iter()
                .map(|line| &line[current_start..max_line])
                .collect::<Vec<_>>();
            total1 += run1(&affected, operators.chars().nth(current_start).unwrap());
            total2 += run(&affected, operators.chars().nth(current_start).unwrap());
        }
    }
    println!("{:?}", total1);
    println!("{:?}", total2);
}

fn run1(slice: &Vec<&str>, operator: char) -> u64 {
    let mut total = if operator == '+' { 0 } else { 1 };
    for s in slice {
        let num = s.trim().parse::<u64>().unwrap();
        if operator == '+' {
            total += num
        } else {
            total *= num
        }
    }
    total
}

fn run(slice: &Vec<&str>, operator: char) -> u64 {
    let len = slice.first().unwrap().len();
    let mut total = if operator == '+' { 0 } else { 1 };

    for i in 0..len {
        let mut s = String::new();
        slice.iter().for_each(|l| s.push(l.chars().nth(i).unwrap()));
        let num = s.trim().parse::<u64>().unwrap();
        if operator == '+' {
            total += num
        } else {
            total *= num
        }
    }
    total
}
