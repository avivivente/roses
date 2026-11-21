extends Control

@onready var animation_player: AnimationPlayer = $AnimationPlayer

func _ready() -> void:
	if not State.has_entered_cave:
		animation_player.play("RESET")
	else:
		animation_player.play("default")
