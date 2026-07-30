class_name Goomba
extends CharacterBody2D

const SPEED: float = 30.0
const DESPAWN_TIME_SEC: float = 1.0
const KNOCKOUT_SPEED: float = Physics.JUMP_SPEED

@onready var sprite: AnimatedSprite2D = $Sprite
@onready var hitbox: Area2D = $Hitbox
@onready var collision_shape: CollisionPolygon2D = $CollisionShape

@export var is_facing_left: bool = true
@export var points: int = ScoreTable.value_of(ScoreTable.Award.GOOMBA_STOMP)

var is_alive: bool = true

var _is_knocked_out: bool = false

const _THEMES = {
	StageManager.StageTheme.OVERWORLD: preload("res://enemies/goomba_frames_overworld.tres"),
	StageManager.StageTheme.UNDERGROUND: preload("res://enemies/goomba_frames_underground.tres"),
}


func _ready():
	_set_theme(StageManager.theme)
	StageManager.connect("theme_changed", _set_theme)


func _physics_process(delta):
	var collision = get_last_slide_collision()

	if collision:
		var normal = collision.get_normal()
		if normal.x:
			is_facing_left = normal.x < 0

	if is_alive:
		velocity.x = -SPEED if is_facing_left else SPEED
	else:
		velocity.x = 0.0

	velocity.y = min(Physics.MAX_FALL_SPEED, velocity.y + Physics.GRAVITY * delta)

	move_and_slide()


func stomp() -> bool:
	if not is_alive:
		return false

	sprite.play("stomp")
	is_alive = false

	get_tree().create_timer(DESPAWN_TIME_SEC).connect("timeout", queue_free)

	return true


func die_from_hit(_hit_direction: Vector2 = Vector2.ZERO, awards_points: bool = true):
	if not is_alive:
		return

	is_alive = false
	_is_knocked_out = true

	collision_shape.set_deferred("disabled", true)
	hitbox.set_deferred("monitoring", false)
	hitbox.set_deferred("monitorable", false)

	sprite.flip_v = true
	velocity.y = KNOCKOUT_SPEED

	if awards_points:
		ScoreManager.award_points(points, global_position + Vector2.UP * 8)


func hit(body: Node2D):
	if body is QuestionBlock:
		die_from_hit(Vector2.UP)


func _set_theme(theme: StageManager.StageTheme):
	sprite.sprite_frames = _THEMES[theme]
	sprite.play(sprite.animation)


func _on_hitbox_area_entered(area: Area2D):
	var body = area.get_parent()

	if body is Player and body.has_cooldown:
		return

	is_facing_left = not is_facing_left


func _on_visibility_enabler_screen_exited():
	if _is_knocked_out:
		queue_free()


func _on_death_timer_timeout():
	queue_free()
