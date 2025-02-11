package main

import (
	_ "embed"
	"fmt"
	"strings"
)

type Point struct {
	x int
	y int
}

//go:embed input.txt
var input string

func main() {
	turns := strings.TrimSpace(input)
	known1 := make(map[Point]struct{})
	known2 := make(map[Point]struct{})

	var x, y int
	var x1, y1 int
	var x2, y2 int
	known1[Point{x1, y1}] = struct{}{}
	known2[Point{x1, y1}] = struct{}{}

	for i, turn := range turns {
		if i%2 == 0 {
			x1, y1 = move(x1, y1, turn)
			known2[Point{x1, y1}] = struct{}{}
		} else {
			x2, y2 = move(x2, y2, turn)
			known2[Point{x2, y2}] = struct{}{}
		}
		x, y = move(x, y, turn)
		known1[Point{x, y}] = struct{}{}
	}

	println("Part1:", len(known1))
	println("Part2:", len(known2))
}

func move(x int, y int, d int32) (int, int) {
	switch d {
	case '^':
		y++
	case '>':
		x++
	case '<':
		x--
	case 'v':
		y--
	default:
		panic(fmt.Sprintf("Unknown direction %c", d))
	}
	return x, y
}
