package main

type item struct {
	cost   int
	damage int
	armor  int
}

const MAX_ROUNDS = 100
const MIN_DAMAGE = 1

var NoItem = item{cost: 0, damage: 0, armor: 0}

// Weapons
var Dagger = item{cost: 8, damage: 4, armor: 0}
var Shortsword = item{cost: 10, damage: 5, armor: 0}
var Warhammer = item{cost: 25, damage: 6, armor: 0}
var Longsword = item{cost: 40, damage: 7, armor: 0}
var Greataxe = item{cost: 74, damage: 8, armor: 0}
var weapons = []item{Dagger, Shortsword, Warhammer, Longsword, Greataxe}

// Armor
var Leather = item{cost: 13, damage: 0, armor: 1}
var Chainmail = item{cost: 31, damage: 0, armor: 2}
var Splintmail = item{cost: 53, damage: 0, armor: 3}
var Bandedmail = item{cost: 75, damage: 0, armor: 4}
var Platemail = item{cost: 102, damage: 0, armor: 5}
var armors = []item{Leather, Chainmail, Splintmail, Bandedmail, Platemail, NoItem}

// Rings
var Damage_1 = item{cost: 25, damage: 1, armor: 0}
var Damage_2 = item{cost: 50, damage: 2, armor: 0}
var Damage_3 = item{cost: 100, damage: 3, armor: 0}
var Defense_1 = item{cost: 20, damage: 0, armor: 1}
var Defense_2 = item{cost: 40, damage: 0, armor: 2}
var Defense_3 = item{cost: 80, damage: 0, armor: 3}
var rings = []item{Damage_1, Damage_2, Damage_3, Defense_1, Defense_2, Defense_3, NoItem}

const HP = 100
const BOSS_HP = 103
const BOSS_DAMAGE = 9
const BOSS_ARMOR = 2

func main() {
	minPrice := 1_000
	maxPrice := 0

	for _, weapon := range weapons {
		for _, armor := range armors {
			for _, ring1 := range rings {
				for _, ring2 := range rings {
					if ring1 == ring2 && ring1 != NoItem {
						continue
					}
					c, d, a := combine(weapon, armor, ring1, ring2)
					win := simulate(HP, d, a)
					if win && c < minPrice {
						minPrice = c
					}
					if !win && c > maxPrice {
						maxPrice = c
					}
				}
			}
		}
	}

	println("Part1:", minPrice)
	println("Part2:", maxPrice)
}

func combine(w item, a item, r1 item, r2 item) (int, int, int) {
	tc := w.cost + a.cost + r1.cost + r2.cost
	td := w.damage + a.damage + r1.damage + r2.damage
	ta := w.armor + a.armor + r1.armor + r2.armor

	return tc, td, ta
}

func simulate(php int, pdamage int, parmor int) bool {
	boss := BOSS_HP
	player := php

	for i := 0; i < MAX_ROUNDS && player > 0 && boss > 0; i++ {
		if i%2 == 0 {
			damage := max(1, pdamage-BOSS_ARMOR)
			boss -= damage
		} else {
			damage := max(1, BOSS_DAMAGE-parmor)
			player -= damage
		}
	}
	return player > 0
}
