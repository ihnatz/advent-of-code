package main

import (
	_ "embed"
	"os"
	"strconv"
	"strings"
)

type computer struct {
	regA int
	regB int
	ptr  int
}

//go:embed input.txt
var input string

func main() {
	instructions := strings.Split(strings.TrimSpace(input), "\n")
	println("Part1:", run(instructions, &computer{}))
	println("Part2:", run(instructions, &computer{regA: 1}))
}

func run(instructions []string, c *computer) int {
	for c.ptr < len(instructions) {
		line := instructions[c.ptr]
		apply(line, c)
	}
	return c.regB
}

func apply(line string, c *computer) {
	parts := strings.Fields(line)
	cmd := parts[0]

	switch cmd {
	case "hlf":
		reg := parts[1]
		c.setVal(reg, c.val(reg)/2)
		c.ptr++
	case "tpl":
		reg := parts[1]
		c.setVal(reg, c.val(reg)*3)
		c.ptr++
	case "inc":
		reg := parts[1]
		c.setVal(reg, c.val(reg)+1)
		c.ptr++
	case "jmp":
		offset, err := strconv.Atoi(parts[1])
		if err != nil {
			panic("Invalid offset in jmp: " + parts[1])
		}
		c.ptr += offset
	case "jie":
		reg := strings.TrimRight(parts[1], ",")
		offset, err := strconv.Atoi(parts[2])
		if err != nil {
			panic("Invalid offset in jie: " + parts[2])
		}
		if c.val(reg)%2 == 0 {
			c.ptr += offset
		} else {
			c.ptr++
		}
	case "jio":
		reg := strings.TrimRight(parts[1], ",")
		offset, err := strconv.Atoi(parts[2])
		if err != nil {
			panic("Invalid offset in jio: " + parts[2])
		}
		if c.val(reg) == 1 {
			c.ptr += offset
		} else {
			c.ptr++
		}
	default:
		panic("Unknown command: " + cmd)
	}
}

func (c *computer) setVal(name string, val int) {
	switch name {
	case "a":
		c.regA = val
	case "b":
		c.regB = val
	default:
		panic("Unknown register: " + name)
		os.Exit(1)
	}
}

func (c *computer) val(name string) int {
	switch name {
	case "a":
		return c.regA
	case "b":
		return c.regB
	default:
		panic("Unknown register: " + name)
		os.Exit(1)
		return -1
	}
}
