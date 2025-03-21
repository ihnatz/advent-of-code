package main

import (
	_ "embed"
	"math"
	"strconv"
	"strings"
)

//go:embed input.txt
var input string

const N = 150

func main() {
	known := make([]int, 0, 20)
	for _, line := range strings.Split(strings.TrimSpace(input), "\n") {
		v, _ := strconv.Atoi(line)
		known = append(known, v)
	}
	target := make([]int, N+1)

	run(known, target, 0, 0)
	println("Part1:", target[N])

	steps := make([]int, N+1)
	for i := range target {
		target[i] = 0
	}
	for i := range steps {
		steps[i] = math.MaxInt32
	}

	runWithSteps(known, target, steps, 0, 0, 0)
	println("Part2:", target[N])

	println("Part1 DP:", runDP(known))
	println("Part2 DP:", runDP2D(known))
}

func runWithSteps(known []int, target []int, steps []int, i int, count int, current int) {
	new_val := current + known[i]
	new_count := count + 1
	if new_val <= N {
		if steps[new_val] == new_count {
			target[new_val]++
		} else if steps[new_val] > new_count {
			steps[new_val] = new_count
			target[new_val] = 1
		} else {
			// nothing to do
		}
	}

	if i+1 < len(known) {
		runWithSteps(known, target, steps, i+1, count+1, new_val)
		runWithSteps(known, target, steps, i+1, count, current)
	}
}

func runDP(known []int) int {
	dp := make([]int, N+1)
	dp[0] = 1
	for _, v := range known {
		for i := N; i >= v; i-- {
			dp[i] += dp[i-v]
		}
	}
	return dp[N]
}

func runDP2D(known []int) int {
	dp := make([][]int, len(known)+1)
	for i := range dp {
		dp[i] = make([]int, N+1)
	}
	dp[0][0] = 1

	for _, v := range known {
		for steps := len(known); steps > 0; steps-- {
			for i := N; i >= v; i-- {
				dp[steps][i] += dp[steps-1][i-v]
			}
		}
	}

	for i := 1; i <= len(known); i++ {
		if dp[i][N] > 0 {
			return dp[i][N]
		}
	}

	return 0
}

func run(known []int, target []int, i int, current int) {
	new_val := current + known[i]
	if new_val <= N {
		target[new_val]++
	}

	if i+1 < len(known) {
		run(known, target, i+1, new_val)
		run(known, target, i+1, current)
	}
}
