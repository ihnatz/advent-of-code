package main

import (
	"cmp"
	_ "embed"
	"maps"
	"slices"
	"strings"
)

//go:embed input.txt
var input string

func main() {
	content := strings.Split(strings.TrimSpace(input), "\n\n")
	transitions := make(map[string][]string)
	reversed := make(map[string]string)

	for _, line := range strings.Split(content[0], "\n") {
		from, to, _ := strings.Cut(line, " => ")
		_, ok := transitions[from]
		if !ok {
			transitions[from] = make([]string, 0)
		}
		transitions[from] = append(transitions[from], to)
		reversed[to] = from
	}

	target := parseFormula(content[1])
	known := make(map[string]interface{})
	for idx, symbol := range target {
		options, ok := transitions[symbol]
		if !ok {
			continue
		}
		for _, option := range options {
			concat := substitude(target, idx, option)
			known[strings.Join(concat, "")] = struct{}{}
		}
	}

	println("Part1:", len(known))
	println("Part2:", unwrap(content[1], reversed))
}

func substitude(current []string, idx int, substitution string) []string {
	option_formula := parseFormula(substitution)
	return slices.Concat(current[:idx], option_formula, current[idx+1:])
}

func unwrap(target string, reversed map[string]string) int {
	byLen := func(a, b string) int {
		return cmp.Compare(len(b), len(a))
	}
	steps := 0
	pattern := slices.SortedFunc(maps.Keys(reversed), byLen)
	current := target
	for current != "e" {
		for _, pattern := range pattern {
			replacement, _ := reversed[pattern]
			if !strings.Contains(current, pattern) {
				continue
			}
			current = strings.Replace(current, pattern, replacement, 1)
			steps++
			break
		}
	}

	return steps
}

func parseFormula(formula string) []string {
	t := make([]string, 0)
	p := false
	c := ""

	for i := 0; i < len(formula); i++ {
		if p {
			if formula[i] >= 'A' && formula[i] <= 'Z' {
				t = append(t, c)
				c = string(formula[i])
			} else {
				c += string(formula[i])
			}
		} else {
			if formula[i] >= 'A' && formula[i] <= 'Z' {
				p = true
				c += string(formula[i])
			} else {
				panic("unreachable")
			}
		}
	}

	t = append(t, c)
	return t
}
