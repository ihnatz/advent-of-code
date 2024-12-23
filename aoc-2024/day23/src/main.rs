use std::collections::HashMap;
use std::collections::HashSet;

fn bron_kerbosch(
    r: &mut HashSet<String>,
    p: &mut HashSet<String>,
    x: &mut HashSet<String>,
    g: &HashMap<String, HashSet<String>>,
    max_clique: &mut HashSet<String>,
) {
    if p.is_empty() && x.is_empty() {
        if r.len() > max_clique.len() {
            max_clique.clear();
            max_clique.extend(r.iter().cloned());
        }
        return;
    }

    let pivot = p
        .iter()
        .chain(x.iter())
        .max_by_key(|v| {
            g.get(*v)
                .map(|neighbors| neighbors.intersection(p).count())
                .unwrap_or(0)
        })
        .cloned();

    let vertices: Vec<_> = if let Some(pivot) = pivot {
        p.difference(&g[&pivot]).cloned().collect()
    } else {
        p.iter().cloned().collect()
    };

    for v in vertices {
        let neighbors = g.get(&v).unwrap();

        let mut new_r = r.clone();
        new_r.insert(v.clone());

        let mut new_p = p.intersection(neighbors).cloned().collect();
        let mut new_x = x.intersection(neighbors).cloned().collect();

        bron_kerbosch(&mut new_r, &mut new_p, &mut new_x, g, max_clique);

        p.remove(&v);
        x.insert(v);
    }
}

fn find_maximum_clique(g: &HashMap<String, HashSet<String>>) -> HashSet<String> {
    let mut r = HashSet::new();
    let mut p: HashSet<String> = g.keys().cloned().collect();
    let mut x = HashSet::new();
    let mut max_clique = HashSet::new();

    bron_kerbosch(&mut r, &mut p, &mut x, g, &mut max_clique);
    max_clique
}

fn main() {
    let input = include_str!("input.txt");
    let pairs: Vec<_> = input
        .lines()
        .map(|line| line.split_once("-").unwrap())
        .collect();
    let mut g = HashMap::new();
    for (l, r) in &pairs {
        g.entry(l.to_string())
            .or_insert(HashSet::new())
            .insert(r.to_string());
        g.entry(r.to_string())
            .or_insert(HashSet::new())
            .insert(l.to_string());
    }

    let mut triplets = HashSet::new();

    for n1 in g.keys() {
        let n1_g = g.get(n1).unwrap();
        for n2 in n1_g {
            let n2_g = g.get(n2).unwrap();
            for n3 in n1_g & n2_g {
                let mut triplet = vec![n1, n2, &n3];
                triplet.sort();
                triplets.insert((triplet[0].clone(), triplet[1].clone(), triplet[2].clone()));
            }
        }
    }

    let p1 = triplets
        .iter()
        .filter(|(a, b, c)| a.starts_with('t') || b.starts_with('t') || c.starts_with('t'))
        .count();
    println!("Part1: {:?}", p1);

    let max_password = find_maximum_clique(&g);
    let mut s: Vec<_> = max_password.iter().cloned().collect();
    s.sort();
    println!("Part2: {}", s.join(","));
}
