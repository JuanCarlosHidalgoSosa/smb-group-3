extends Node

const GRAVITY = 1300.0
const MAX_FALL_SPEED = 270.0
const JUMP_SPEED = -240.0

@onready var _level = $"../Main/Stage"


func _process(_delta):
	# Returns -1.0 when the refresh rate can't be determined (headless, some drivers).
	var refresh_rate = DisplayServer.screen_get_refresh_rate()

	if refresh_rate > 0.0:
		Engine.physics_ticks_per_second = round(refresh_rate)


func disable():
	_toggle_children_physics(_level, false)
	GameLog.append("Physics disabled")


func enable():
	_toggle_children_physics(_level, true)
	GameLog.append("Physics enabled")


func _toggle_children_physics(node: Node, value: bool):
	for child in node.get_children():
		child.set_physics_process(value)

		if child is AnimatedSprite2D:
			if value:
				child.play()
			else:
				child.stop()

		_toggle_children_physics(child, value)
