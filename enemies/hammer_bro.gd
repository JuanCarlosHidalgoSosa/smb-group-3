class_name HammerBro
extends CharacterBody2D

const SPEED: float = 30.0
const KNOCKOUT_SPEED: float = Physics.JUMP_SPEED

const _FRAMES = preload("res://enemies/hammer_bro_frames.tres")

const _THEMES = {
	StageManager.StageTheme.OVERWORLD: _FRAMES,
	StageManager.StageTheme.UNDERGROUND: _FRAMES,
}

const hammer_scene = preload("res://enemies/hammer.tscn")

@onready var sprite: AnimatedSprite2D = $Sprite
@onready var hitbox: Area2D = $Hitbox
@onready var collision_shape: CollisionShape2D = $CollisionShape

@export var is_facing_left: bool = true
@export var walk_range: float = 24.0
@export var throw_interval_sec: float = 2.0
@export var points: int = ScoreTable.value_of(ScoreTable.Award.HAMMER_BRO)

var is_alive: bool = true

var _origin_x: float = 0.0
var _throw_timer: float = 0.0
var _fall_speed: float = 0.0


func _ready():
	_set_theme(StageManager.theme)
	StageManager.connect("theme_changed", _set_theme)

	_origin_x = global_position.x
	_throw_timer = throw_interval_sec


func _physics_process(delta):
	if not is_alive:
		_fall_speed = min(Physics.MAX_FALL_SPEED, _fall_speed + Physics.GRAVITY * delta)
		position.y += _fall_speed * delta
		return

	var collision = get_last_slide_collision()

	if collision and collision.get_normal().x:
		is_facing_left = collision.get_normal().x < 0
	elif global_position.x <= _origin_x - walk_range:
		is_facing_left = false
	elif global_position.x >= _origin_x + walk_range:
		is_facing_left = true

	velocity.x = -SPEED if is_facing_left else SPEED
	velocity.y = min(Physics.MAX_FALL_SPEED, velocity.y + Physics.GRAVITY * delta)

	move_and_slide()

	sprite.flip_h = not is_facing_left

	_throw_timer -= delta

	if _throw_timer <= 0.0:
		_throw_timer = throw_interval_sec
		throw_hammer()


func throw_hammer():
	var hammer = hammer_scene.instantiate()

	hammer.position = position + Vector2(0, -20)
	add_sibling(hammer)
	hammer.throw(_is_player_on_the_left())


func stomp() -> bool:
	if not is_alive:
		return false

	_knock_out()

	return true


func die_from_hit(_hit_direction: Vector2 = Vector2.ZERO, awards_points: bool = true):
	if not is_alive:
		return

	_knock_out()

	if awards_points:
		ScoreManager.award_points(points, global_position + Vector2.UP * 8)


func hit(body: Node2D):
	if body is QuestionBlock:
		die_from_hit(Vector2.UP)


func _knock_out():
	is_alive = false

	collision_shape.set_deferred("disabled", true)
	hitbox.set_deferred("monitoring", false)
	hitbox.set_deferred("monitorable", false)

	sprite.flip_v = true
	_fall_speed = KNOCKOUT_SPEED


func _is_player_on_the_left() -> bool:
	var player = get_tree().get_first_node_in_group("player")

	if not player:
		return is_facing_left

	return player.global_position.x < global_position.x


func _set_theme(theme: StageManager.StageTheme):
	sprite.sprite_frames = _THEMES[theme]
	sprite.play(sprite.animation)


func _on_visibility_enabler_screen_exited():
	if not is_alive:
		queue_free()
