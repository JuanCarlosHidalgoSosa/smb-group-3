extends CanvasLayer

signal time_up

@export var initial_time: int = 300
@export var speed: float = 0.4 # Every 0.4s it goes down 1 unit

var time: int

@onready var timer = $Timer
@onready var timer_label = $Control/HBoxContainer/timer_label
@onready var score_label: Label = $Control/HBoxContainer/Score

var _player_name: String = ""

func _ready():
	time = initial_time
	timer.wait_time = speed
	update_time()
	timer.start()

	_player_name = score_label.text.split("\n")[0]
	ScoreManager.score_changed.connect(_on_score_changed)
	_on_score_changed(ScoreManager.score)

func _on_timer_timeout():
	if time > 0:
		time -= 1
		update_time()
	else:
		timer.stop()
		emit_signal("time_up")

func update_time():
	timer_label.text = "TIME\n%03d" % time

func _on_score_changed(score: int):
	score_label.text = "%s\n%06d" % [_player_name, score]
