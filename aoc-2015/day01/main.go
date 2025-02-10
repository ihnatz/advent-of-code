package main

import (
	_ "embed"
	"strings"
)

//go:embed input.txt
var input string

func main() {
	var floor int
	basement := -1

	for i, c := range strings.TrimSpace(input) {
		if floor == -1 && basement == -1 {
			basement = i
		}

		switch c {
		case '(':
			floor++
		case ')':
			floor--
		}
	}

	println("Part1:", floor)
	println("Part2:", basement)
}
