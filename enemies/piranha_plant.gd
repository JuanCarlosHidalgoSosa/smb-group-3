class_name PiranhaPlant
extends Node2D

enum Phase { HIDDEN, RISING, OUT, LOWERING }

const HEIGHT: float = 24.0
const MOVE_SPEED: float = 60.0
const KNOCKOUT_SPEED: float = Physics.JUMP_SPEED

const _FRAMES = preload("res://enemies/piranha_plant_frames.tres")

const _THEMES = {
	StageManager.StageTheme.OVERWORLD: _FRAMES,
	StageManager.StageTheme.UNDERGROUND: _FRAMES,
}

@onready var sprite: AnimatedSprite2D = $Sprite
@onready var hitbox: Area2D = $Hitbox
@onready var hitbox_shape: CollisionShape2D = $Hitbox/Shape

@export var time_in_sec: float = 2.0
@export var time_out_sec: float = 2.0
@export var player_margin: float = 32.0
@export var points: int = ScoreTable.value_of(ScoreTable.Award.PIRANHA_PLANT)

var is_alive: bool = true
var phase: Phase = Phase.HIDDEN

var _mouth_position: Vector2 = Vector2.ZERO
var _height: float = 0.0
var _timer: float = 0.0
var _fall_speed: float = 0.0


func _ready():
	_set_theme(StageManager.theme)
	StageManager.connect("theme_changed", _set_theme)

	_mouth_position = global_position
	_timer = time_in_sec
	_update_body()


func _physics_process(delta):
	if not is_alive:
		_fall_speed = min(Physics.MAX_FALL_SPEED, _fall_speed + Physics.GRAVITY * delta)
		position.y += _fall_speed * delta
		return

	match phase:
		Phase.HIDDEN:
			_timer -= delta

			if _timer <= 0.0 and not is_player_near():
				phase = Phase.RISING

		Phase.RISING:
			_height = min(HEIGHT, _height + MOVE_SPEED * delta)

			if _height >= HEIGHT:
				phase = Phase.OUT
				_timer = time_out_sec

		Phase.OUT:
			_timer -= delta

			if _timer <= 0.0:
				phase = Phase.LOWERING

		Phase.LOWERING:
			_height = max(0.0, _height - MOVE_SPEED * delta)

			if _height <= 0.0:
				phase = Phase.HIDDEN
				_timer = time_in_sec

	_update_body()


func is_player_near() -> bool:
	var player = get_tree().get_first_node_in_group("player")

	if not player:
		return false

	return absf(player.global_position.x - _mouth_position.x) < player_margin


func die_from_hit(_hit_direction: Vector2 = Vector2.ZERO, awards_points: bool = true):
	if not is_alive:
		return

	is_alive = false

	hitbox.set_deferred("monitoring", false)
	hitbox.set_deferred("monitorable", false)

	z_index = 0
	sprite.visible = true
	sprite.flip_v = true
	_fall_speed = KNOCKOUT_SPEED

	if awards_points:
		ScoreManager.award_points(points, global_position + Vector2.UP * 8)


func _update_body():
	global_position.y = _mouth_position.y + HEIGHT - _height

	var is_hidden = _height <= 0.0

	sprite.visible = not is_hidden

	if hitbox_shape.disabled != is_hidden:
		hitbox_shape.set_deferred("disabled", is_hidden)


func _set_theme(theme: StageManager.StageTheme):
	sprite.sprite_frames = _THEMES[theme]
	sprite.play(sprite.animation)


func _on_visibility_enabler_screen_exited():
	if not is_alive:
		queue_free()
