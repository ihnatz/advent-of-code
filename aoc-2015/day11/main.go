package main

const INPUT = "hxbxwxba"

func main() {
	seq1 := run([]byte(INPUT))
	seq2 := run(seq1)
	println("Part1:", string(seq1))
	println("Part2:", string(seq2))
}

func run(seq []byte) []byte {
	for {
		seq = next(seq)
		if hasThreeInRow(seq) && noConfusing(seq) && hasTwoPairs(seq) {
			break
		}
	}
	return seq
}

func next(prev []byte) []byte {
	next := make([]byte, len(prev))
	copy(next, prev)
	for idx := len(prev) - 1; idx >= 0; idx-- {
		if next[idx] != 'z' {
			next[idx]++
			return next
		} else {
			next[idx] = 'a'
		}
	}
	return next
}

func hasThreeInRow(seq []byte) bool {
	for i := 0; i < len(seq)-2; i++ {
		a, b, c := seq[i], seq[i+1], seq[i+2]
		if c-b == 1 && b-a == 1 {
			return true
		}
	}
	return false
}

func noConfusing(seq []byte) bool {
	for _, val := range seq {
		if val == 'i' || val == 'o' || val == 'l' {
			return false
		}
	}
	return true
}

func hasTwoPairs(seq []byte) bool {
	var count int
	var i int

	for i < len(seq)-1 {
		if seq[i] == seq[i+1] {
			count++
			i += 2
		} else {
			i++
		}

		if count >= 2 {
			return true
		}
	}

	return false
}
