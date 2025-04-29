package main

import (
	_ "embed"
	"math"
	"math/bits"
	"strconv"
	"strings"
)

//go:embed input.txt
var input string

func main() {
	var total int
	weights := make([]int, 0, 15)
	for _, raw := range strings.Split(strings.TrimSpace(input), "\n") {
		val, err := strconv.Atoi(raw)
		if err == nil {
			weights = append(weights, val)
		} else {
			panic("Can't parse value: " + raw)
		}
		total += val
	}

	println("Part1:", best(weights, total/3))
	println("Part2:", best(weights, total/4))
}

func best(weights []int, expected int) int {
	n := len(weights)
	bestCount := n
	bestQE := int(math.Inf(1))

	for subset := 1; subset < int(math.Pow(2, float64(n))); subset++ {
		itemsCount := bits.OnesCount(uint(subset))
		if itemsCount > bestCount {
			continue
		}

		total := 0
		qe := 1
		for i := 0; i < n; i++ {
			if subset>>i&1 == 1 {
				total += weights[i]
				qe *= weights[i]
				if total > expected {
					break
				}
			}
		}
		if total != expected {
			continue
		}
		if itemsCount == bestCount {
			bestQE = min(bestQE, qe)
		} else {
			bestCount = itemsCount
			bestQE = qe
		}
	}
	return bestQE
}
