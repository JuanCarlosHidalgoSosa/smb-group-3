class_name BillBlaster
extends StaticBody2D

const MOUTH_OFFSET: Vector2 = Vector2(12, -16)

const bullet_scene = preload("res://enemies/bullet_bill.tscn")

@export var fire_interval_sec: float = 2.0
@export var fire_range: float = 200.0
@export var min_distance: float = 32.0

var _timer: float = 0.0


func _ready():
	_timer = fire_interval_sec


func _physics_process(delta):
	var distance = _distance_to_player()

	if is_inf(distance) or absf(distance) > fire_range or absf(distance) < min_distance:
		return

	_timer -= delta

	if _timer > 0.0:
		return

	_timer = fire_interval_sec
	fire(distance < 0.0)


func fire(towards_left: bool):
	var bullet = bullet_scene.instantiate()

	bullet.is_facing_left = towards_left
	bullet.position = position + Vector2(
		-MOUTH_OFFSET.x if towards_left else MOUTH_OFFSET.x,
		MOUTH_OFFSET.y
	)

	add_sibling(bullet)


func _distance_to_player() -> float:
	var player = get_tree().get_first_node_in_group("player")

	if not player:
		return INF

	return player.global_position.x - global_position.x
