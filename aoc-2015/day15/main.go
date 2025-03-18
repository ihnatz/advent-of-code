package main

import (
	_ "embed"
	"strconv"
	"strings"
)

//go:embed input.txt
var input string

const K = 100
const E = 500

type ingredient struct {
	name       string
	capacity   int
	durability int
	flavor     int
	texture    int
	calories   int
}

func main() {
	known := make([]ingredient, 0, 10)
	for _, line := range strings.Split(strings.TrimSpace(input), "\n") {
		parts := strings.Split(strings.TrimRight(strings.TrimSpace(line), "."), " ")
		known = append(known, ingredient{
			name:       strings.TrimRight(parts[0], ":"),
			capacity:   parsePart(parts[2]),
			durability: parsePart(parts[4]),
			flavor:     parsePart(parts[6]),
			texture:    parsePart(parts[8]),
			calories:   parsePart(parts[10]),
		})
	}

	maxScore := 0
	maxScoreWithCalories := 0
	counts := make([]int, len(known), len(known))
	for i := 0; i < len(known); i++ {
		counts[i] = 1
	}

loop:
	for {
		counts[0]++
		for i := 0; i < len(known); i++ {
			if counts[i] == K {
				counts[i] = 1
				if (i + 1) == len(known) {
					break loop
				}
				counts[i+1]++
			}
		}
		if sum(counts) == K {
			score := calculate(counts, known, false)
			scoreWithCalories := calculate(counts, known, true)
			if score > maxScore {
				maxScore = score
			}
			if scoreWithCalories > maxScoreWithCalories {
				maxScoreWithCalories = scoreWithCalories
			}
		}
	}

	println("Part1:", maxScore)
	println("Part2:", maxScoreWithCalories)
}

func calculate(val []int, known []ingredient, withCalories bool) int {
	var cap, dur, flv, txt, cal int

	for i, v := range val {
		cap += known[i].capacity * v
		dur += known[i].durability * v
		flv += known[i].flavor * v
		txt += known[i].texture * v
		cal += known[i].calories * v
	}
	if cap <= 0 || dur <= 0 || flv <= 0 || txt <= 0 {
		return 0
	}
	if withCalories && cal != E {
		return 0
	}
	return cap * dur * flv * txt
}

func sum(val []int) int {
	var t int
	for _, v := range val {
		t += v
	}
	return t
}

func parsePart(part string) int {
	v, _ := strconv.Atoi(strings.TrimRight(part, ","))
	return v
}
