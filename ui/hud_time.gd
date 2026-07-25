extends CanvasLayer


signal time_up

@export var initial_time: int = 300
@export var speed: float = 0.4 # Every 0.4s it goes down 1 unit
var time: int
@onready var timer = $Timer
@onready var timer_label = $Control/HBoxContainer/timer_label

func _ready():
	time = initial_time
	timer.wait_time = speed
	update_time()
	timer.start()

func _on_timer_timeout():
	if time > 0:
		time -= 1
		update_time()
	else:
		timer.stop()
		emit_signal("time_up")

func update_time():
	timer_label.text = "TIME\n%03d" % time
