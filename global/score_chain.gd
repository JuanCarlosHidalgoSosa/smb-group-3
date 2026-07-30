class_name ScoreChain
extends RefCounted

var link: int = 0


func reset():
	link = 0


func award(base_points: int, world_position: Vector2):
	if ScoreTable.chain_gives_one_up(link):
		LivesManager.add_life()
		ScoreManager.show_floating_text(ScoreTable.ONE_UP_TEXT, world_position)
	else:
		ScoreManager.award_points(_value(base_points), world_position)

	link += 1


func _value(base_points: int) -> int:
	if link == 0:
		return base_points

	return ScoreTable.chain_value(link)
