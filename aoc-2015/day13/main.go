package main

import (
	_ "embed"
	"strconv"
	"strings"
)

//go:embed input.txt
var input string

const N = 10

func main() {
	known := map[string]int{}
	happiness := generateMatrix(N)

	for _, line := range strings.Split(strings.TrimSpace(input), "\n") {
		parts := strings.Split(strings.TrimRight(strings.TrimSpace(line), "."), " ")
		value, _ := strconv.Atoi(parts[3])
		if parts[2] == "lose" {
			value *= -1
		}
		happiness[personId(parts[0], known)][personId(parts[10], known)] = value
	}

	println("Part1:", run(known, happiness))
	known["me"] = len(known)
	println("Part2:", run(known, happiness))
}

func run(known map[string]int, happiness [][]int) int {
	maxHappiness := 0
	count := len(known)
	q := make([][]int, 0)
	for i := 0; i < count; i++ {
		q = append(q, []int{i})
	}

	for len(q) > 0 {
		current := q[0]
		q = q[1:]

		person := current[len(current)-1]
		for candidate := 0; candidate < count; candidate++ {
			if person == candidate || contains(current, candidate) {
				continue
			}

			new_path := make([]int, len(current))
			copy(new_path, current)
			new_path = append(new_path, candidate)

			if len(new_path) == count {
				x := calcualteHappiness(new_path, happiness)
				if x > maxHappiness {
					maxHappiness = x
				}
			} else {
				q = append(q, new_path)
			}
		}
	}
	return maxHappiness
}

func calcualteHappiness(path []int, matrix [][]int) int {
	total := 0

	first := path[0]
	last := path[len(path)-1]

	current := first
	for _, neigh := range path {
		total += matrix[current][neigh]
		current = neigh
	}
	total += matrix[last][first]

	current = last
	for i, _ := range path {
		neigh := path[len(path)-i-1]
		total += matrix[current][neigh]
		current = neigh
	}
	total += matrix[first][last]

	return total
}

func generateMatrix(N int) [][]int {
	matrix := make([][]int, N)
	for i := range matrix {
		matrix[i] = make([]int, N)
	}
	return matrix
}

func personId(name string, known map[string]int) int {
	val, ok := known[name]
	if ok {
		return val
	}
	count := len(known)
	known[name] = count
	return count
}

func contains(slice []int, val int) bool {
	for _, item := range slice {
		if item == val {
			return true
		}
	}
	return false
}
