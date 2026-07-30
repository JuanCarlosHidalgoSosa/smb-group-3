class_name Mushroom
extends Powerup

const SPEED: float = 60.0

var _is_facing_left: bool = false


func _physics_process(delta):
	var collision = get_last_slide_collision()

	if collision:
		var normal = collision.get_normal()
		if normal.x:
			_is_facing_left = normal.x < 0

	velocity.x = -SPEED if _is_facing_left else SPEED
	velocity.y = min(Physics.MAX_FALL_SPEED, velocity.y + Physics.GRAVITY * delta)

	move_and_slide()


func hit(body: Node2D):
	if body is QuestionBlock:
		velocity.y = Physics.JUMP_SPEED
		_is_facing_left = body.position.x > position.x
