class_name Fireball
extends CharacterBody2D

const SUB_PIXEL_SPEED: float = 15.0 / 4.0
const SUB_PIXEL_ACCELERATION: float = 225.0
const PIXELS_PER_FRAME: float = 60.0

const SPEED: float = 64.0 * SUB_PIXEL_SPEED
const GRAVITY: float = 4.0 * SUB_PIXEL_ACCELERATION
const MAX_FALL_SPEED: float = 80.0 * SUB_PIXEL_SPEED
const BOUNCE_SPEED: float = -3.0 * PIXELS_PER_FRAME

const SPIN_INTERVAL_SEC: float = 0.05

const GROUP: StringName = &"fireballs"

@onready var sprite: AnimatedSprite2D = $Sprite
@onready var hitbox: Area2D = $Hitbox
@onready var collision_shape: CollisionShape2D = $CollisionShape

var is_facing_left: bool = false

var _is_exploding: bool = false
var _spin_time: float = 0.0
var _spin_frame: int = 0


func launch(towards_left: bool):
	is_facing_left = towards_left


func _physics_process(delta):
	if _is_exploding:
		return

	_process_spin(delta)

	velocity.x = -SPEED if is_facing_left else SPEED
	velocity.y = min(MAX_FALL_SPEED, velocity.y + GRAVITY * delta)

	move_and_slide()

	if is_on_wall():
		explode()
	elif is_on_floor():
		velocity.y = BOUNCE_SPEED
	elif is_on_ceiling():
		velocity.y = 0.0


func explode():
	if _is_exploding:
		return

	_is_exploding = true
	velocity = Vector2.ZERO

	collision_shape.set_deferred("disabled", true)
	hitbox.set_deferred("monitoring", false)
	hitbox.set_deferred("monitorable", false)

	sprite.flip_h = false
	sprite.flip_v = false
	sprite.play("explode")

	await sprite.animation_finished

	queue_free()


func _process_spin(delta: float):
	_spin_time += delta

	if _spin_time < SPIN_INTERVAL_SEC:
		return

	_spin_time = 0.0
	_spin_frame = (_spin_frame + 1) % 4

	sprite.flip_h = _spin_frame == 1 or _spin_frame == 2
	sprite.flip_v = _spin_frame >= 2


func _on_hitbox_area_entered(area: Area2D):
	var body = area.get_parent()

	if not body.is_in_group("enemies") or not body.is_alive:
		return

	if Attack.can_hurt(body, Attack.Type.FIRE) and body.has_method("die_from_hit"):
		body.die_from_hit(Vector2.LEFT if is_facing_left else Vector2.RIGHT)

	explode()


func _on_visibility_enabler_screen_exited():
	queue_free()
