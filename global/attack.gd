class_name Attack
extends RefCounted

enum Type { STOMP, SHELL, FIRE, STAR, BLOCK }


static func can_hurt(enemy: Node, type: Type) -> bool:
	if not enemy.has_method("is_immune_to"):
		return true

	return not enemy.is_immune_to(type)
