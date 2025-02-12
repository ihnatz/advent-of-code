package main

import (
	"crypto/md5"
	"encoding/hex"
	"fmt"
)

func main() {
	input := "yzbqklnj"

	var fiveZeros int
	var sixZeros int

	for {
		fiveZeros++
		result := getMD5Hash(input + fmt.Sprint(fiveZeros))[:5]
		if result == "00000" {
			break
		}
	}

	sixZeros = fiveZeros
	for {
		sixZeros++
		result := getMD5Hash(input + fmt.Sprint(sixZeros))[:6]
		if result == "000000" {
			break
		}
	}

	println("Part1:", fiveZeros)
	println("Part2:", sixZeros)
}

func getMD5Hash(text string) string {
	hash := md5.Sum([]byte(text))
	return hex.EncodeToString(hash[:])
}
