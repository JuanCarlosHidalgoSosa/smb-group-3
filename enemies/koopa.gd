class_name Koopa
extends CharacterBody2D

enum State { WALKING, SHELL, SLIDING }

const SPEED: float = 30.0
const SHELL_SPEED: float = 150.0
const KNOCKOUT_SPEED: float = Physics.JUMP_SPEED

const SHELL_WAKE_SEC: float = 5.0
const SHELL_BLINK_SEC: float = 1.0
const SHELL_BLINK_INTERVAL_SEC: float = 0.1

const _FRAMES = preload("res://enemies/koopa_frames.tres")

const _THEMES = {
	StageManager.StageTheme.OVERWORLD: _FRAMES,
	StageManager.StageTheme.UNDERGROUND: _FRAMES,
}

@onready var sprite: AnimatedSprite2D = $Sprite
@onready var hitbox: Area2D = $Hitbox
@onready var walk_hitbox_shape: CollisionShape2D = $Hitbox/Walk
@onready var shell_hitbox_shape: CollisionShape2D = $Hitbox/Shell
@onready var walk_collision_shape: CollisionShape2D = $WalkCollisionShape
@onready var shell_collision_shape: CollisionShape2D = $ShellCollisionShape

@export var is_facing_left: bool = true
@export var points: int = ScoreTable.value_of(ScoreTable.Award.KOOPA_STOMP)

var is_alive: bool = true
var state: State = State.WALKING

var _is_knocked_out: bool = false
var _shell_time_left: float = 0.0
var _chain: ScoreChain = ScoreChain.new()


func _ready():
	_set_theme(StageManager.theme)
	StageManager.connect("theme_changed", _set_theme)
	_update_shapes()


func _physics_process(delta):
	if state == State.SHELL:
		_process_shell(delta)

	var collision = get_last_slide_collision()

	if collision:
		var normal = collision.get_normal()
		if normal.x:
			is_facing_left = normal.x < 0

	if is_alive and state != State.SHELL:
		var speed = SHELL_SPEED if state == State.SLIDING else SPEED
		velocity.x = -speed if is_facing_left else speed
	else:
		velocity.x = 0.0

	velocity.y = min(Physics.MAX_FALL_SPEED, velocity.y + Physics.GRAVITY * delta)

	move_and_slide()

	if state == State.WALKING:
		sprite.flip_h = not is_facing_left


func stomp() -> bool:
	if not is_alive:
		return false

	var was_walking = state == State.WALKING

	_enter_shell()

	return was_walking


func kick(direction: float) -> bool:
	if not is_alive or state != State.SHELL:
		return false

	is_facing_left = direction < 0.0
	state = State.SLIDING
	_chain.reset()
	_play("shell")

	return true


func die_from_hit(_hit_direction: Vector2 = Vector2.ZERO, awards_points: bool = true):
	if not is_alive:
		return

	is_alive = false
	_is_knocked_out = true
	state = State.SHELL

	walk_collision_shape.set_deferred("disabled", true)
	shell_collision_shape.set_deferred("disabled", true)
	hitbox.set_deferred("monitoring", false)
	hitbox.set_deferred("monitorable", false)

	_play("shell")
	sprite.flip_v = true
	velocity.y = KNOCKOUT_SPEED

	if awards_points:
		ScoreManager.award_points(points, global_position + Vector2.UP * 8)


func hit(body: Node2D):
	if body is QuestionBlock:
		die_from_hit(Vector2.UP)


func _process_shell(delta: float):
	_shell_time_left -= delta

	if _shell_time_left <= 0.0:
		_wake_up()
		return

	if _shell_time_left > SHELL_BLINK_SEC:
		return

	var is_blinking = int(_shell_time_left / SHELL_BLINK_INTERVAL_SEC) % 2 == 0
	_play("shell_wake" if is_blinking else "shell")


func _enter_shell():
	state = State.SHELL
	_shell_time_left = SHELL_WAKE_SEC
	_chain.reset()
	velocity.x = 0.0

	_update_shapes()
	_play("shell")


func _wake_up():
	state = State.WALKING

	_update_shapes()
	_play("walk")


func _update_shapes():
	var is_walking = state == State.WALKING

	walk_collision_shape.set_deferred("disabled", not is_walking)
	shell_collision_shape.set_deferred("disabled", is_walking)
	walk_hitbox_shape.set_deferred("disabled", not is_walking)
	shell_hitbox_shape.set_deferred("disabled", is_walking)


func _play(animation: String):
	if sprite.animation != animation:
		sprite.play(animation)


func _set_theme(theme: StageManager.StageTheme):
	sprite.sprite_frames = _THEMES[theme]
	sprite.play(sprite.animation)


func _on_hitbox_area_entered(area: Area2D):
	var body = area.get_parent()

	if body is Player:
		return

	if not body.is_in_group("enemies"):
		return

	if state == State.SLIDING:
		if body.is_alive and body.has_method("die_from_hit"):
			body.die_from_hit(Vector2.LEFT if is_facing_left else Vector2.RIGHT, false)
			_chain.award(body.points, body.global_position + Vector2.UP * 8)

		return

	if state == State.WALKING:
		is_facing_left = not is_facing_left


func _on_visibility_enabler_screen_exited():
	if _is_knocked_out:
		queue_free()
