package main

import (
	_ "embed"
	"strconv"
	"strings"
)

//go:embed input.txt
var input string

const T = 2503

type raindeer struct {
	name  string
	speed int
	time  int
	rest  int
}

func main() {
	known := make([]raindeer, 0, 10)

	for _, line := range strings.Split(strings.TrimSpace(input), "\n") {
		parts := strings.Split(strings.TrimRight(strings.TrimSpace(line), "."), " ")
		speed, _ := strconv.Atoi(parts[3])
		time, _ := strconv.Atoi(parts[6])
		rest, _ := strconv.Atoi(parts[13])
		r := raindeer{
			name:  parts[0],
			speed: speed,
			time:  time,
			rest:  rest,
		}
		known = append(known, r)
	}
	maxDistance := 0
	for _, r := range known {
		d := r.cover(T)
		if d > maxDistance {
			maxDistance = d
		}
	}

	println("Part1:", maxDistance)

	points := make([]int, len(known), len(known))
	atSecond := make([]int, len(known), len(known))

	for t := 1; t <= T; t++ {
		for i, r := range known {
			atSecond[i] = r.cover(t)
		}
		maxValue := maxVal(atSecond)
		for j := 0; j < len(atSecond); j++ {
			if atSecond[j] == maxValue {
				points[j]++
			}
		}
	}

	println("Part2:", maxVal(points))

}

func maxVal(m []int) int {
	mv := m[0]
	for _, v := range m {
		if v > mv {
			mv = v
		}
	}
	return mv
}

func (r *raindeer) cycleLong() int {
	return r.time + r.rest
}

func (r *raindeer) cycleLen() int {
	return r.time * r.speed
}

func (r *raindeer) cover(t int) int {
	cycles := t / r.cycleLong()
	remain := t - (cycles * r.cycleLong())

	return cycles*r.cycleLen() + min(remain, r.time)*r.speed
}
