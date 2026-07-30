extends Area2D

signal level_completed

const POLE_HEIGHT = 694.0
const POINTS_BY_SEGMENT = [5000, 2000, 800, 400, 200, 100]
const WALK_SPEED = 60.0
const MIN_REACHABLE_OFFSET = 40.0  # distancia entre el punto más bajo alcanzable y la base visual del asta

var _triggered = false

func _on_body_entered(body: Node):
	if _triggered:
		return
	if not body is Player:
		return
	
	_triggered = true
	_start_sequence(body)

func _start_sequence(player: Node):
	var hud = get_tree().current_scene.get_node_or_null("HUD")
	if hud:
		hud.pause_timer()
	var stage = get_tree().current_scene.get_node_or_null("Stage")
	var castle = stage.get_node_or_null("CastleEntrance") if stage else null
	var ground_y = castle.global_position.y if castle else global_position.y + 400.0
	
	var actual_pole_height = ground_y - global_position.y - MIN_REACHABLE_OFFSET
	var relative_y = player.global_position.y - global_position.y
	relative_y = clamp(relative_y, 0.0, actual_pole_height)
	
	var segment_height = actual_pole_height / 6.0
	var segment_index = int(relative_y / segment_height)
	segment_index = clamp(segment_index, 0, 5)
	
	var points = POINTS_BY_SEGMENT[segment_index]
	
	ScoreManager.award_points(points, player.global_position)
	
	var flag_node = get_node_or_null("flag")
	if flag_node:
		var flag_target_y = (ground_y - global_position.y - 20.0) / scale.y
		var flag_tween = create_tween()
		flag_tween.tween_property(flag_node, "position:y", flag_target_y, 1.5)
	
	player.play_flagpole_sequence(global_position, ground_y, points)
	
	level_completed.emit()
	
