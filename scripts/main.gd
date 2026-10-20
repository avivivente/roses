extends Node2D



func _setup_level(level_root: Node) -> void:
	var player = level_root.get_node("Player")
	$HUD.set_player(player)
