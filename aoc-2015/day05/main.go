package main

import (
	_ "embed"
	"strings"
)

//go:embed input.txt
var input string

func main() {
	lines := strings.Split(strings.TrimSpace(input), "\n")
	var total1, total2 int

	for _, word := range lines {
		if threeVowels(word) && anythingTwice(word) && noConsecuitive(word) {
			total1++
		}
		if repeatWithLetter(word) && pairOfAnyTwo(word) {
			total2++
		}
	}

	println("Part1:", total1)
	println("Part2:", total2)
}

func threeVowels(word string) bool {
	var count int
	for _, c := range word {
		if strings.ContainsRune("aeiou", c) {
			count++
			if count == 3 {
				return true
			}
		}
	}
	return false
}

func anythingTwice(word string) bool {
	var lastLetter int32
	for _, c := range word {
		if lastLetter == c {
			return true
		}
		lastLetter = c
	}
	return false
}

func noConsecuitive(word string) bool {
	for i := 0; i < len(word)-1; i++ {
		pair := word[i : i+2]
		if pair == "ab" || pair == "cd" || pair == "pq" || pair == "xy" {
			return false
		}
	}
	return true
}

func pairOfAnyTwo(word string) bool {
	for i := 0; i < len(word)-1; i++ {
		firstPair := word[i : i+2]
		for j := i + 2; j < len(word)-1; j++ {
			secondPair := word[j : j+2]
			if firstPair == secondPair {
				return true
			}
		}
	}
	return false
}

func repeatWithLetter(word string) bool {
	var a, b, c int32
	for _, current := range word {
		a = b
		b = c
		c = current
		if a == c {
			return true
		}
	}
	return false
}
