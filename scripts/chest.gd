extends StaticBody2D

@onready var animation_player: AnimationPlayer = $AnimationPlayer
@onready var interaction_area: InteractionArea = $InteractionArea

var is_open: bool = false

func _ready():
	interaction_area.interact = Callable(self, "_open_chest")


func _open_chest():
	if is_open: return
	
	is_open = true
	animation_player.play("open")


func _on_interaction_area_body_exited(body: Node2D) -> void:
	if is_open and body.name == "Player":
		is_open = false
		animation_player.play_backwards("open")
