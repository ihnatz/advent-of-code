package main

import (
	_ "embed"
	"strconv"
	"strings"
)

//go:embed input.txt
var input string

func main() {
	linesPart1 := strings.Split(strings.TrimSpace(input), "\n")
	wiresPart1 := make(map[string]int)
	processLines(linesPart1, wiresPart1, func(aft string) bool { return false })
	part1 := wiresPart1["a"]

	linesPart2 := strings.Split(strings.TrimSpace(input), "\n")
	wiresPart2 := make(map[string]int)
	wiresPart2["b"] = part1
	processLines(linesPart2, wiresPart2, func(aft string) bool { return aft == "b" })

	println("Part1:", part1)
	println("Part2:", wiresPart2["a"])
}

func processLines(lines []string, wires map[string]int, skip func(string) bool) {
	for len(lines) > 0 {
		line := lines[0]
		lines = lines[1:]
		bef, aft, _ := strings.Cut(line, " -> ")
		if skip(aft) {
			continue
		}
		val, ok := apply(wires, bef)
		if ok {
			wires[aft] = val & 0xFFFF
		} else {
			lines = append(lines, line)
		}
	}
}

func parseValue(wires map[string]int, value string) (int, bool) {
	if val, err := strconv.Atoi(value); err == nil {
		return val, true
	}
	val, ok := wires[value]
	if ok {
		return val, true
	}
	return -1, false
}

func apply(wires map[string]int, operand string) (int, bool) {
	if val, err := strconv.Atoi(operand); err == nil {
		return val, true
	}

	parts := strings.Fields(operand)
	switch len(parts) {
	case 1:
		val, ok := parseValue(wires, operand)
		if !ok {
			return -1, false
		}
		return val, true
	case 2:
		val, ok := parseValue(wires, parts[1])
		if !ok {
			return -1, false
		}
		return ^val, true
	case 3:
		left := parts[0]
		operator := parts[1]
		right := parts[2]

		lVal, ok := parseValue(wires, left)
		if !ok {
			return -1, false
		}

		rVal, ok := parseValue(wires, right)
		if !ok {
			return -1, false
		}

		switch operator {
		case "AND":
			return lVal & rVal, true
		case "OR":
			return lVal | rVal, true
		case "LSHIFT":
			return lVal << rVal, true
		case "RSHIFT":
			return lVal >> rVal, true
		}
	default:
		panic("unknown operand")
	}

	return -1, false
}
