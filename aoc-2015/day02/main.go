package main

import (
	_ "embed"
	"strconv"
	"strings"
)

//go:embed input.txt
var input string

func main() {
	var totalPaper int
	var totalRibbon int
	lines := strings.Split(strings.TrimSpace(input), "\n")
	for _, line := range lines {
		parts := strings.Split(line, "x")
		w, err := strconv.Atoi(parts[0])
		if err != nil {
			panic("can't parse w")
		}
		h, err := strconv.Atoi(parts[1])
		if err != nil {
			panic("can't parse h")
		}
		l, err := strconv.Atoi(parts[2])
		if err != nil {
			panic("can't parse l")
		}
		totalPaper += CalculatePaper(w, h, l)
		totalRibbon += CalculateRibbon(w, h, l)
	}

	println("Part1:", totalPaper)
	println("Part2:", totalRibbon)
}

func CalculatePaper(w int, h int, l int) int {
	minSurface := min(l*w, w*h, h*l)
	return 2*l*w + 2*w*h + 2*h*l + minSurface
}

func CalculateRibbon(w int, h int, l int) int {
	minPerimeter := min(l+w, w+h, h+l) * 2
	return l*w*h + minPerimeter
}
