extends Node

const RESTART_DELAY = 5.0

func _ready():
	await get_tree().create_timer(RESTART_DELAY).timeout
	_go_to_title()

func _unhandled_input(event):
	if event.is_pressed():
		_go_to_title()

func _go_to_title():
	get_tree().change_scene_to_file("res://main.tscn")
