class_name RedMushroom
extends Mushroom


func apply_to(player: Player):
	player.transform(Player.State.BIG)
