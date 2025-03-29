package main

import (
	"math"
)

type effect struct {
	turns  int
	armor  int
	damage int
	mana   int
}

type spell struct {
	cost   int
	damage int
	heal   int
	extra  effect
}

var (
	MissileSpell  = spell{cost: 53, damage: 4}
	DrainSpell    = spell{cost: 73, damage: 2, heal: 2}
	ShieldSpell   = spell{cost: 113, extra: effect{turns: 6, armor: 7}}
	PoisonSpell   = spell{cost: 173, extra: effect{turns: 6, damage: 3}}
	RechargeSpell = spell{cost: 229, extra: effect{turns: 5, mana: 101}}
)
var spells = []spell{MissileSpell, DrainSpell, ShieldSpell, PoisonSpell, RechargeSpell}

type gameState struct {
	playerHp, playerMp, bossHp              int
	shieldTurns, poisonTurns, rechargeTurns int
}

const HP = 50
const MP = 500

const BOSS_HP = 71
const BOSS_DAMAGE = 10

var minMana = math.MaxInt32

func main() {
	state := gameState{
		playerHp: HP,
		playerMp: MP,
		bossHp:   BOSS_HP,
	}

	run(0, 0, state, false)
	println("Part1:", minMana)

	minMana = math.MaxInt32
	run(0, 0, state, true)
	println("Part2:", minMana)
}

func run(mana int, round int, state gameState, hard bool) {
	if hard && round%2 == 0 {
		state.playerHp--
	}
	if mana > minMana || state.playerHp <= 0 {
		return
	}
	if state.bossHp <= 0 {
		if mana < minMana {
			minMana = mana
		}
		return
	}

	armor := 0
	// Apply effects
	if state.shieldTurns != 0 {
		armor += ShieldSpell.extra.armor
	}
	if state.poisonTurns != 0 {
		state.bossHp -= PoisonSpell.extra.damage
	}
	if state.rechargeTurns != 0 {
		state.playerMp += RechargeSpell.extra.mana
	}
	state.shieldTurns = max(state.shieldTurns-1, 0)
	state.poisonTurns = max(state.poisonTurns-1, 0)
	state.rechargeTurns = max(state.rechargeTurns-1, 0)
	////////////////////////////////////////////////////////////////////////////

	if state.bossHp <= 0 {
		if mana < minMana {
			minMana = mana
		}
		return
	}

	if round%2 == 1 {
		damage := max(BOSS_DAMAGE-armor, 1)
		state.playerHp -= damage
		run(mana, round+1, state, hard)
	} else {
		for _, s := range spells {
			if state.playerMp < s.cost {
				continue
			}
			newState := state
			switch s {
			case MissileSpell:
				newState.bossHp -= MissileSpell.damage
			case DrainSpell:
				newState.playerHp += DrainSpell.heal
				newState.bossHp -= DrainSpell.damage
			case ShieldSpell:
				if state.shieldTurns > 0 {
					continue
				}
				newState.shieldTurns = ShieldSpell.extra.turns
			case PoisonSpell:
				if state.poisonTurns > 0 {
					continue
				}
				newState.poisonTurns = PoisonSpell.extra.turns
			case RechargeSpell:
				if state.rechargeTurns > 0 {
					continue
				}
				newState.rechargeTurns = RechargeSpell.extra.turns
			}
			newState.playerMp -= s.cost
			run(mana+s.cost, round+1, newState, hard)
		}
	}
}
