package main

import (
	_ "embed"
	"strings"
)

//go:embed input.txt
var input string

func main() {
	lines := strings.Split(strings.TrimSpace(input), "\n")

	var full, encoded, decoded int
	for _, line := range lines {
		decoded += decode(line)
		encoded += encode(line)
		full += len(line)
	}

	println("Part1:", full-decoded)
	println("Part2:", encoded-full)
}

func encode(line string) int {
	encodeLen := 2
	for _, ch := range line {
		encodeLen++
		if ch == '"' || ch == '\\' {
			encodeLen++
		}
	}
	return encodeLen
}

func decode(line string) int {
	var decodeLen int
	var escaping bool

	for i := 1; i < len(line)-1; i++ {
		ch := line[i]
		if escaping {
			decodeLen++
			escaping = false
			if ch == 'x' {
				i += 2
			}
		} else {
			if ch == '\\' {
				escaping = true
			} else {
				decodeLen++
			}
		}
	}
	return decodeLen
}
