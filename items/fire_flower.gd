class_name FireFlower
extends Powerup


func apply_to(player: Player):
	if player.state == Player.State.SMALL:
		player.transform(Player.State.BIG)
	else:
		player.transform(Player.State.FIRE)
