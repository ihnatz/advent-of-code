package main

const E = 34000000
const COST1 = 10
const COST2 = 11
const MAX_HOUSES = 50
const MAX_N = 1_000_000

func main() {
	houses := make([]int, MAX_N)

	for i := 1; i < MAX_N; i++ {
		for j := i; j < MAX_N; j += i {
			houses[j] += i
		}
	}
	for i := 0; i < MAX_N; i++ {
		if houses[i] >= (E / COST1) {
			println("Part1:", i)
			break
		}
	}

	for i := 0; i < MAX_N; i++ {
		houses[i] = 0
	}

	for i := 1; i < MAX_N; i++ {
		for j := 1; j < MAX_HOUSES && i*j < MAX_N; j++ {
			houses[(i * j)] += i
		}
	}
	for i := 0; i < MAX_N; i++ {
		if houses[i] >= (E / COST2) {
			println("Part2:", i)
			break
		}
	}
}
