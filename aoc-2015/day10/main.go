package main

const INPUT = "1113122113"
const CONWAYS_CONSTANT = 1.303577269034
const GROWTH_MARGIN = 0.1
const GROWTH = CONWAYS_CONSTANT + GROWTH_MARGIN
const N1 = 40
const N2 = 50

func main() {
	seq := []byte(INPUT)

	for i := 0; i < N2; i++ {
		seq = expand(seq)
		if i + 1 == N1 {
			println("Part1:", len(seq))
		}
	}
	println("Part2:", len(seq))
}

func expand(value []byte) []byte {
	cap := int(float64(len(value)) * GROWTH)
	out := make([]byte, 0, cap)

	count := 1
	current := value[0]
	for i := 1; i < len(value); i++ {
		if value[i] == current {
			count++
		} else {
			out = append(out, byte('0' + count), current)
			current = value[i]
			count = 1
		}
	}
	out = append(out, byte('0' + count), current)

	return out
}
