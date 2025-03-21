package main

import (
	_ "embed"
	"strings"
)

//go:embed input.txt
var input string
var ALIVE = struct{}{}

const N = 100

func main() {
	var n int
	alive := make(map[int]any)
	content := strings.Split(strings.TrimSpace(input), "\n")

	for y, line := range content {
		n = len(line)
		for x, v := range line {
			if v == '#' {
				idx := n * y + x
				alive[idx] = ALIVE
			}
		}
	}
	m := len(content[0])
	original := make(map[int]any)
    for key, value := range alive {
        original[key] = value
    }

	for i := 0; i < N; i++ {
		alive = nextGeneration(alive, n, m)
	}
	println("Part1:", len(alive))


	alive = original
	fillCorners(alive, n, m)
	for i := 0; i < N; i++ {
		alive = nextGeneration(alive, n, m)
		fillCorners(alive, n, m)
	}
	println("Part2:", len(alive))
}

func fillCorners(alive map[int]any, n int, m int) {
	alive[0] = ALIVE
	alive[m - 1] = ALIVE
	alive[n * (m - 1)] = ALIVE
	alive[n * m - 1] = ALIVE
}

func xyIdx(x int, y int, n int) int {
	return n * y + x
}

func countNeighbors(alive map[int]any, n int, m int, x int, y int) int {
	total := 0
	for dx := -1; dx < 2; dx++ {
		for dy := -1; dy < 2; dy++ {
			if dx == 0 && dy == 0 {
				continue
			}
			nx := x + dx
			ny := y + dy
			if nx < 0 || ny < 0 || nx >= m || ny >= n {
				continue
			}
			idx := xyIdx(nx, ny, n)
			_, ok := alive[idx]
			if ok {
				total++
			}
		}
	}
	return total
}

func nextGeneration(alive map[int]any, n int, m int) map[int]any {
	newAlive := make(map[int]any)

	for y := 0; y < n; y++ {
		for x := 0; x < m; x++ {
			idx := xyIdx(x, y, n)
			_, ok := alive[idx]
			neigh := countNeighbors(alive, n, m, x, y)
			if ok {
				if neigh == 2 || neigh == 3 {
					newAlive[idx] = 1
				}
			} else {
				if neigh == 3 {
					newAlive[idx] = 1
				}
			}
		}
	}
	return newAlive
}

func printMap(alive map[int]any, n int, m int) {
	for y := 0; y < n; y++ {
		for x := 0; x < m; x++ {
			idx := xyIdx(x, y, n)
			_, ok := alive[idx]
			if ok {
				print("#")
			} else {
				print(".")
			}
		}
		println()
	}
}
