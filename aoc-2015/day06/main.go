package main

import (
	_ "embed"
	"regexp"
	"strconv"
	"strings"
)

//go:embed input.txt
var input string

type Action int

const (
	TurnOn Action = iota
	TurnOff
	Toggle
)

type action struct {
	op     Action
	x1, y1 int
	x2, y2 int
}

var numberRe = regexp.MustCompile("[0-9]+")

func newAction(actionType Action, desc string) action {
	values := numberRe.FindAllString(desc, -1)
	x1, err := strconv.Atoi(values[0])
	if err != nil {
		panic("can't parse x1")
	}
	y1, err := strconv.Atoi(values[1])
	if err != nil {
		panic("can't parse y1")
	}
	x2, err := strconv.Atoi(values[2])
	if err != nil {
		panic("can't parse x2")
	}
	y2, err := strconv.Atoi(values[3])
	if err != nil {
		panic("can't parse y2")
	}

	return action{
		actionType,
		x1, y1, x2, y2,
	}
}

const W = 1000
const H = 1000

func main() {
	lines := strings.Split(strings.TrimSpace(input), "\n")

	actions := make([]action, len(lines))

	for i, command := range lines {
		var a action
		switch {
		case strings.HasPrefix(command, "turn on"):
			a = newAction(TurnOn, command)
		case strings.HasPrefix(command, "turn off"):
			a = newAction(TurnOff, command)
		case strings.HasPrefix(command, "toggle"):
			a = newAction(Toggle, command)
		default:
			panic("Unknown command: " + command)
		}
		actions[i] = a
	}

	var gridSwitch [W * H]bool
	var gridLevel [W * H]int

	for _, a := range actions {
		applySwitch(gridSwitch[:], a)
		applyTune(gridLevel[:], a)
	}

	var t1 int
	for _, v := range gridSwitch {
		if v {
			t1++
		}
	}

	var t2 int
	for _, v := range gridLevel {
		t2 += v
	}
	println("Part1:", t1)
	println("Part2:", t2)
}

func applyTune(area []int, a action) {
	for x := a.x1; x <= a.x2; x++ {
		for y := a.y1; y <= a.y2; y++ {
			i := x*W + y
			switch a.op {
			case TurnOn:
				area[i]++
			case TurnOff:
				area[i] = max(0, area[i]-1)
			case Toggle:
				area[i] += 2
			}
		}
	}

}

func applySwitch(area []bool, a action) {
	for x := a.x1; x <= a.x2; x++ {
		for y := a.y1; y <= a.y2; y++ {
			i := x*W + y
			switch a.op {
			case TurnOn:
				area[i] = true
			case TurnOff:
				area[i] = false
			case Toggle:
				area[i] = !area[i]
			}
		}
	}
}
