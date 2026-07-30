class_name Star
extends Powerup

const SUB_PIXEL_SPEED: float = 15.0 / 4.0
const SUB_PIXEL_ACCELERATION: float = 225.0
const PIXELS_PER_FRAME: float = 60.0

const SPEED: float = 16.0 * SUB_PIXEL_SPEED
const GRAVITY: float = 4.0 * SUB_PIXEL_ACCELERATION
const MAX_FALL_SPEED: float = 72.0 * SUB_PIXEL_SPEED
const BOUNCE_SPEED: float = -4.0 * PIXELS_PER_FRAME

var _is_facing_left: bool = false


func _physics_process(delta):
	velocity.x = -SPEED if _is_facing_left else SPEED
	velocity.y = min(MAX_FALL_SPEED, velocity.y + GRAVITY * delta)

	move_and_slide()

	if is_on_wall():
		_is_facing_left = get_wall_normal().x < 0.0

	if is_on_floor():
		velocity.y = BOUNCE_SPEED


func hit(body: Node2D):
	if body is QuestionBlock:
		velocity.y = BOUNCE_SPEED
		_is_facing_left = body.position.x > position.x


func apply_to(player: Player):
	player.start_invincibility()
