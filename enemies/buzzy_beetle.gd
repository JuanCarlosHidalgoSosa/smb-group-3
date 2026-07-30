class_name BuzzyBeetle
extends Koopa

const _BUZZY_THEMES = {
	StageManager.StageTheme.OVERWORLD: preload("res://enemies/buzzy_beetle_frames_overworld.tres"),
	StageManager.StageTheme.UNDERGROUND: preload("res://enemies/buzzy_beetle_frames_underground.tres"),
}


func is_immune_to(attack: Attack.Type) -> bool:
	return attack == Attack.Type.FIRE


func _set_theme(theme: StageManager.StageTheme):
	sprite.sprite_frames = _BUZZY_THEMES[theme]
	sprite.play(sprite.animation)
