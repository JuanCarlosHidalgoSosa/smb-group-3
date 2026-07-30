class_name BulletBill
extends Node2D

const SPEED: float = 90.0
const KNOCKOUT_SPEED: float = Physics.JUMP_SPEED

const _FRAMES = preload("res://enemies/bullet_bill_frames.tres")

const _THEMES = {
	StageManager.StageTheme.OVERWORLD: _FRAMES,
	StageManager.StageTheme.UNDERGROUND: _FRAMES,
}

@onready var sprite: AnimatedSprite2D = $Sprite
@onready var hitbox: Area2D = $Hitbox

@export var is_facing_left: bool = true
@export var points: int = ScoreTable.value_of(ScoreTable.Award.BULLET_BILL)

var is_alive: bool = true

var _fall_speed: float = 0.0


func _ready():
	_set_theme(StageManager.theme)
	StageManager.connect("theme_changed", _set_theme)
	sprite.flip_h = not is_facing_left


func _physics_process(delta):
	if is_alive:
		position.x += (-SPEED if is_facing_left else SPEED) * delta
		return

	_fall_speed = min(Physics.MAX_FALL_SPEED, _fall_speed + Physics.GRAVITY * delta)
	position.y += _fall_speed * delta


func stomp() -> bool:
	if not is_alive:
		return false

	_neutralize()
	queue_free()

	return true


func die_from_hit(_hit_direction: Vector2 = Vector2.ZERO, awards_points: bool = true):
	if not is_alive:
		return

	_neutralize()

	sprite.flip_v = true
	_fall_speed = KNOCKOUT_SPEED

	if awards_points:
		ScoreManager.award_points(points, global_position + Vector2.UP * 8)


func _neutralize():
	is_alive = false
	hitbox.set_deferred("monitoring", false)
	hitbox.set_deferred("monitorable", false)


func _set_theme(theme: StageManager.StageTheme):
	sprite.sprite_frames = _THEMES[theme]
	sprite.play(sprite.animation)


func _on_visibility_enabler_screen_exited():
	queue_free()
