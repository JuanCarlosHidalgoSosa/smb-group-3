extends Node

signal score_changed(score: int)
signal coins_changed(coins: int)

var score: int = 0
var coins: int = 0

func add_points(amount: int) -> void:
	score += amount
	score_changed.emit(score)

func add_coin() -> void:
	coins += 1
	coins_changed.emit(coins)
