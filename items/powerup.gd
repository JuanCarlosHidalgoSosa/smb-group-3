class_name Powerup
extends CharacterBody2D

@onready var sprite = $Sprite
@onready var collision_shape: CollisionShape2D = $CollisionShape

@export var points: int = ScoreTable.value_of(ScoreTable.Award.POWERUP)
@export var extra_lives: int = 0

var spawner: Node = null


func _ready():
	if spawner is QuestionBlock:
		setup_block_animation()


func setup_block_animation():
	set_physics_process(false)
	sprite.visible = false
	collision_shape.disabled = true

	await spawner.hit_finished

	var _z_index = sprite.z_index
	sprite.z_index = -1
	sprite.visible = true
	sprite.offset = Vector2.DOWN * 16

	var tween = get_tree().create_tween()
	tween.tween_property(sprite, "offset", Vector2.ZERO, 1)

	await tween.finished

	sprite.z_index = _z_index
	collision_shape.disabled = false
	set_physics_process(true)


func apply_to(_player: Player):
	pass
