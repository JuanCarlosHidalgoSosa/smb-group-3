class_name ScoreTable
extends RefCounted

enum Award {
	GOOMBA_STOMP,
	BRICK_BLOCK_BROKEN,
	POWERUP,
	COIN,
}

const VALUES: Dictionary = {
	Award.GOOMBA_STOMP: 100,
	Award.BRICK_BLOCK_BROKEN: 50,
	Award.POWERUP: 1000,
	Award.COIN: 200,
}


static func value_of(award: Award) -> int:
	return VALUES.get(award, 0)
