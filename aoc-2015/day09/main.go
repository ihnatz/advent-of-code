package main

import (
	_ "embed"
	"math"
	"strings"
	"strconv"
)

//go:embed input.txt
var input string

const N = 10

func main() {
	lines := strings.Split(strings.TrimSpace(input), "\n")
	cities := make(map[string]int)

	matrix := make([][]int, N)
	for i := range matrix {
    	matrix[i] = make([]int, N)
	}

	var count int

	for _, line := range lines {
		desc, rawDistance, _ := strings.Cut(line, " = ")
		fromCity, toCity, _ := strings.Cut(desc, " to ")
        distance, _ := strconv.Atoi(rawDistance)

		fromIdx, ok := cities[fromCity]
		if !ok {
			cities[fromCity] = count
			fromIdx = count
			count++
		}
		toIdx, ok := cities[toCity]
		if !ok {
			cities[toCity] = count
			toIdx = count
			count++
		}
		matrix[fromIdx][toIdx] = distance
		matrix[toIdx][fromIdx] = distance
	}

	shortest := math.MaxInt
	longest := 0

	q := make([][]int, 0)
	for i := 0; i < count; i++ {
	    q = append(q, []int{i})
	}


	for len(q) > 0 {
		current := q[0]
		q = q[1:]

		city := current[len(current) - 1]
		for candidate := 0; candidate < count; candidate++ {
			if matrix[city][candidate] == 0 || contains(current, candidate) {
				continue
			}

			new_path := make([]int, len(current))
			copy(new_path, current)
			new_path = append(new_path, candidate)

			if len(new_path) == count {
				dist := calculate(new_path, matrix)
				shortest = min(shortest, dist)
				longest = max(longest, dist)
			} else {
				q = append(q, new_path)
			}
		}
	}

	println("Part1:", shortest)
	println("Part2:", longest)
}

func calculate(slice []int, matrix [][]int) int {
	total := 0
	current := slice[0]
	for i, v := range slice {
		if i == 0 {
			continue
		}
		total += matrix[current][v]
		current = v
	}
	return total
}

func contains(slice []int, val int) bool {
    for _, item := range slice {
        if item == val {
            return true
        }
    }
    return false
}
