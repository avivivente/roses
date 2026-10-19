extends Area2D

@onready var timer: Timer = $Timer

var player_dying: bool = false


func _on_body_entered(body: Node2D) -> void:
	if not body.is_in_group("player"):
		return

	if body.is_in_group("hidden"):
		return

	if player_dying:
		return

	player_dying = true
	print("You Died!", get_path())

	Engine.time_scale = 1
	timer.start()


func _on_timer_timeout() -> void:
	Engine.time_scale = 1
	get_tree().reload_current_scene()
