extends CanvasLayer

@onready var score_label: Label = $Control/HBoxContainer/Score

@onready var coins_label: Label = $Control/HBoxContainer/Coins

var _player_name: String = ""

func _ready():

	_player_name = score_label.text.split("\n")[0]

	ScoreManager.score_changed.connect(_on_score_changed)
	ScoreManager.coins_changed.connect(_on_coins_changed)

	_on_score_changed(ScoreManager.score)
	_on_coins_changed(ScoreManager.coins)


func _on_score_changed(score: int):
	score_label.text = "%s\n%06d" % [_player_name, score]
func _on_coins_changed(coins: int):
	coins_label.text = "%02d" % coins
