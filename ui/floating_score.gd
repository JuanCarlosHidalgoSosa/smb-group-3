class_name FloatingScore
extends Node2D

const RISE_HEIGHT: float = 16.0
const LIFESPAN_SEC: float = 1.0

var text: String = ""

@onready var label: Label = $Label

var _elapsed: float = 0.0
var _risen: float = 0.0


func _ready():
	label.text = text

	var text_size = label.get_minimum_size()

	label.size = text_size
	label.position = Vector2(-round(text_size.x / 2.0), -round(text_size.y))


func _physics_process(delta):
	_elapsed += delta

	if _elapsed >= LIFESPAN_SEC:
		queue_free()
		return

	var risen = round(RISE_HEIGHT * _elapsed / LIFESPAN_SEC)
	position.y -= risen - _risen
	_risen = risen
