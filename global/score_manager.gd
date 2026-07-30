extends Node

signal score_changed(score: int)
signal coins_changed(coins: int)

const FLOATING_SCORE_SCENE = preload("res://ui/floating_score.tscn")
const COINS_PER_LIFE: int = 100

var score: int = 0
var coins: int = 0

func add_points(amount: int) -> void:
	score += amount
	score_changed.emit(score)

func award_points(amount: int, world_position: Vector2) -> void:
	add_points(amount)
	show_floating_text(str(amount), world_position)

func show_floating_text(text: String, world_position: Vector2) -> void:
	var stage = _get_stage()

	if not stage:
		return

	var floating_score = FLOATING_SCORE_SCENE.instantiate()
	floating_score.text = text

	stage.add_child(floating_score)
	floating_score.global_position = world_position.round()

func add_coin() -> void:
	coins += 1

	if coins >= COINS_PER_LIFE:
		coins -= COINS_PER_LIFE
		LivesManager.add_life()

	coins_changed.emit(coins)

func _get_stage() -> Node:
	var scene = get_tree().current_scene

	if not scene:
		return null

	return scene.get_node_or_null("Stage")
