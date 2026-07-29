extends Node

signal lives_changed(lives: int)
signal game_over

const INITIAL_LIVES: int = 3

var lives: int = INITIAL_LIVES

func add_life(amount: int = 1) -> void:
	lives += amount
	lives_changed.emit(lives)

func remove_life(amount: int = 1) -> void:
	lives -= amount
	lives_changed.emit(lives)
	if lives <= 0:
		game_over.emit()
		get_tree().change_scene_to_file("res://global/game_over.tscn")

func get_lives() -> int:
	return lives

func reset_lives() -> void:
	lives = INITIAL_LIVES
	lives_changed.emit(lives)
