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

const CHAIN: Array[int] = [100, 200, 400, 500, 800, 1000, 2000, 4000, 5000, 8000]

const ONE_UP_TEXT: String = "1UP"


static func value_of(award: Award) -> int:
	return VALUES.get(award, 0)


static func chain_gives_one_up(link: int) -> bool:
	return link >= CHAIN.size()


static func chain_value(link: int) -> int:
	if chain_gives_one_up(link):
		return 0

	return CHAIN[link]
