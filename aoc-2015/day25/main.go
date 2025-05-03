package main

func main() {
	println(seqAt(getNUmberAt(3010, 3019)))
}

func modExp(base, exp, mod int) int {
	result := 1
	base = base % mod
	for exp > 0 {
		if exp%2 == 1 {
			result = (result * base) % mod
		}
		base = (base * base) % mod
		exp = exp >> 1
	}
	return result
}

func seqAt(n int) int {
	now := 20151125
	mod := 33554393
	base := 252533
	power := modExp(base, n-1, mod)
	return (now * power) % mod
}

func getNUmberAt(r int, c int) int {
	sumIndex := r + c - 1
	triangularPart := (sumIndex * (sumIndex - 1)) / 2
	return triangularPart + c
}
