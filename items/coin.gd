class_name Coin
extends Area2D

const _THEMES = {
	StageManager.StageTheme.OVERWORLD: preload("res://items/coin_frames_overworld.tres"),
	StageManager.StageTheme.UNDERGROUND: preload("res://items/coin_frames_underground.tres"),
}

const coin_particle_scene = preload("res://particles/coin_particle.tscn")

@export var points: int = ScoreTable.value_of(ScoreTable.Award.COIN)

@onready var sprite: AnimatedSprite2D = $Sprite

var _is_collected: bool = false


func _ready():
	_set_theme(StageManager.theme)
	StageManager.connect("theme_changed", _set_theme)


func collect():
	if _is_collected:
		return

	_is_collected = true

	ScoreManager.add_coin()
	ScoreManager.add_points(points)

	var particle = coin_particle_scene.instantiate()
	particle.position = position
	add_sibling(particle)

	queue_free()


func _set_theme(theme: StageManager.StageTheme):
	sprite.sprite_frames = _THEMES[theme]
	sprite.play(sprite.animation)


func _on_area_entered(area: Area2D):
	if area.get_parent() is Player:
		collect()
