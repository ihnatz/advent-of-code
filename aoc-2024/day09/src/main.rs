const EMPTY: i64 = -1;
type Node = (i64, u64);

fn merge_triplets(buff: &mut Vec<Node>) {
    let mut idx = 0;
    let mut sum = 0;
    for chunk in buff.windows(3) {
        if chunk[0].0 == EMPTY && chunk[1].0 == EMPTY && chunk[2].0 == EMPTY {
            sum = chunk[0].1 + chunk[1].1 + chunk[2].1;
            break;
        }
        idx += 1;
    }
    if sum != 0 {
        buff[idx] = (EMPTY, sum);
        buff.drain(idx + 1..=idx + 2);
    }
}

fn merge_duplets(buff: &mut Vec<Node>) {
    let mut idx = 0;
    let mut sum = 0;
    for chunk in buff.windows(2) {
        if chunk[0].0 == EMPTY && chunk[1].0 == EMPTY {
            sum = chunk[0].1 + chunk[1].1;
            break;
        }
        idx += 1;
    }
    if sum != 0 {
        buff[idx] = (EMPTY, sum);
        buff.remove(idx + 1);
    }
}

fn main() {
    let input = include_str!("input.txt").trim();

    let p1 = checksum(&direct_swap(input));
    let p2 = checksum_dense(&block_swap(input));
    println!("Part1: {:?}", p1);
    println!("Part2: {:?}", p2);
}

#[allow(dead_code)]
fn print_buff(buff: &[Node]) {
    for (val, count) in buff {
        for _ in 0..*count {
            print!(
                "{}",
                if *val == EMPTY {
                    String::from(".")
                } else {
                    val.to_string()
                }
            );
        }
    }
    println!();
}

fn block_swap(input: &str) -> Vec<Node> {
    let mut cur = 0;
    let mut buff: Vec<Node> = Vec::new();
    for (idx, count) in input.bytes().enumerate() {
        let count = count - b'0';
        let val = if idx % 2 == 1 {
            0
        } else {
            cur += 1;
            cur
        };

        if count > 0 {
            buff.push(((val - 1) as i64, count as u64));
        }
    }

    let mut id_number = buff.iter().map(|(val, _count)| *val).max().unwrap();

    while id_number > 0 {
        let id_idx = buff
            .iter()
            .position(|(val, _count)| *val == id_number)
            .unwrap();
        let id_node = buff[id_idx];

        let insert_idx = (0..id_idx)
            .find(|&i| {
                let (val, count) = buff[i];
                val == EMPTY && count >= id_node.1
            })
            .unwrap_or(id_idx);

        if insert_idx != id_idx {
            let empty_left = buff[insert_idx].1 - id_node.1;
            buff.swap(insert_idx, id_idx);

            if empty_left != 0 {
                buff.insert(insert_idx + 1, (EMPTY, empty_left));
                buff[id_idx + 1] = (EMPTY, id_node.1);

                merge_triplets(&mut buff);
                merge_duplets(&mut buff);
            }
        }
        id_number -= 1;
    }
    buff
}



fn direct_swap(input: &str) -> Vec<i64> {
    let mut cur = 0;
    let mut buff: Vec<i64> = Vec::new();

    for (idx, count) in input.bytes().enumerate() {
        let count = count - b'0';
        let val = if idx % 2 == 1 {
            0
        } else {
            cur += 1;
            cur
        };

        for _ in 0..count {
            buff.push(val - 1);
        }
    }

    let mut l = 0;
    let mut r = buff.len() - 1;

    while l <= r {
        while buff[l] != EMPTY {
            l += 1;
        }
        if l < r {
            buff.swap(l, r);
            while buff[r] == EMPTY {
                r -= 1;
            }
        }
    }
    buff[0..=r].to_vec()
}

fn checksum(buff: &[i64]) -> i64 {
    buff.iter()
        .enumerate()
        .map(|(idx, val)| *val * idx as i64)
        .sum::<i64>()
}

fn checksum_dense(buff: &[Node]) -> i64 {
    let mut idx = 0;
    let mut checksum: i64 = 0;

    for (val, count) in buff {
        if *val == EMPTY {
            idx += count;
            continue;
        }
        for _ in 0..*count {
            checksum += *val * idx as i64 ;
            idx += 1
        }
    }
    checksum
}
