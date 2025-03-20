package main

import (
	_ "embed"
	"strconv"
	"strings"
)

//go:embed input.txt
var input string

const UNKNOWN = -1

type sue struct {
	name        string
	children    int
	cats        int
	samoyeds    int
	pomeranians int
	akitas      int
	vizslas     int
	goldfish    int
	trees       int
	cars        int
	perfumes    int
}

func main() {
	known := make([]sue, 0, 500)
	for _, line := range strings.Split(strings.TrimSpace(input), "\n") {
		splited := strings.SplitN(strings.TrimRight(strings.TrimSpace(line), "."), ": ", 2)
		parts := strings.Split(splited[1], ", ")

		s := sue{name: splited[0],
			children:    UNKNOWN,
			cats:        UNKNOWN,
			samoyeds:    UNKNOWN,
			pomeranians: UNKNOWN,
			akitas:      UNKNOWN,
			vizslas:     UNKNOWN,
			goldfish:    UNKNOWN,
			trees:       UNKNOWN,
			cars:        UNKNOWN,
			perfumes:    UNKNOWN,
		}
		for i, _ := range parts {
			kind, amount := parsePart(parts[i])
			switch kind {
			case "children":
				s.children = amount
			case "cats":
				s.cats = amount
			case "samoyeds":
				s.samoyeds = amount
			case "pomeranians":
				s.pomeranians = amount
			case "akitas":
				s.akitas = amount
			case "vizslas":
				s.vizslas = amount
			case "goldfish":
				s.goldfish = amount
			case "trees":
				s.trees = amount
			case "cars":
				s.cars = amount
			case "perfumes":
				s.perfumes = amount
			}
		}
		known = append(known, s)
	}

	target := sue{
		children:    3,
		cats:        7,
		samoyeds:    2,
		pomeranians: 3,
		akitas:      0,
		vizslas:     0,
		goldfish:    5,
		trees:       3,
		cars:        2,
		perfumes:    1,
	}

	for i := range known {
		candidate := known[i]
		if matchSue1(candidate, target) {
			println("Part1:", candidate.name)
		}
		if matchSue2(candidate, target) {
			println("Part2:", candidate.name)
		}

	}
}

func matchSue1(candidate, target sue) bool {
	return (candidate.children == UNKNOWN || candidate.children == target.children) &&
		(candidate.samoyeds == UNKNOWN || candidate.samoyeds == target.samoyeds) &&
		(candidate.pomeranians == UNKNOWN || candidate.pomeranians < target.pomeranians) &&
		(candidate.akitas == UNKNOWN || candidate.akitas == target.akitas) &&
		(candidate.vizslas == UNKNOWN || candidate.vizslas == target.vizslas) &&
		(candidate.cars == UNKNOWN || candidate.cars == target.cars) &&
		(candidate.perfumes == UNKNOWN || candidate.perfumes == target.perfumes) &&
		(candidate.cats == UNKNOWN || candidate.cats == target.cats) &&
		(candidate.goldfish == UNKNOWN || candidate.goldfish == target.goldfish) &&
		(candidate.trees == UNKNOWN || candidate.trees == target.trees)
}

func matchSue2(candidate, target sue) bool {
	return (candidate.children == UNKNOWN || candidate.children == target.children) &&
		(candidate.samoyeds == UNKNOWN || candidate.samoyeds == target.samoyeds) &&
		(candidate.pomeranians == UNKNOWN || candidate.pomeranians < target.pomeranians) &&
		(candidate.akitas == UNKNOWN || candidate.akitas == target.akitas) &&
		(candidate.vizslas == UNKNOWN || candidate.vizslas == target.vizslas) &&
		(candidate.cars == UNKNOWN || candidate.cars == target.cars) &&
		(candidate.perfumes == UNKNOWN || candidate.perfumes == target.perfumes) &&
		(candidate.cats == UNKNOWN || candidate.cats > target.cats) &&
		(candidate.goldfish == UNKNOWN || candidate.goldfish < target.goldfish) &&
		(candidate.trees == UNKNOWN || candidate.trees > target.trees)

}

func parsePart(part string) (string, int) {
	parts := strings.Split(part, ": ")
	v, _ := strconv.Atoi(parts[1])
	return parts[0], v
}
