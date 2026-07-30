class_name Hammer
extends Node2D

const THROW_SPEED: Vector2 = Vector2(60.0, -240.0)
const SPIN_SPEED: float = 12.0

var is_alive: bool = true

var _velocity: Vector2 = Vector2.ZERO


func throw(towards_left: bool):
	_velocity = Vector2(-THROW_SPEED.x if towards_left else THROW_SPEED.x, THROW_SPEED.y)


func _physics_process(delta):
	_velocity.y = min(Physics.MAX_FALL_SPEED, _velocity.y + Physics.GRAVITY * delta)
	position += _velocity * delta
	rotation += SPIN_SPEED * delta * (-1.0 if _velocity.x < 0.0 else 1.0)


func _on_visibility_enabler_screen_exited():
	queue_free()
