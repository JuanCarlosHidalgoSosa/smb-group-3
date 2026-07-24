extends CanvasLayer

@onready var score_label: Label = $Control/HBoxContainer/Score

var _player_name: String = ""


func _ready():
	_player_name = score_label.text.split("\n")[0]

	ScoreManager.score_changed.connect(_on_score_changed)
	_on_score_changed(ScoreManager.score)


func _on_score_changed(score: int):
	score_label.text = "%s\n%06d" % [_player_name, score]
