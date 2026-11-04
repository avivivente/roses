extends Area2D

@onready var player: CharacterBody2D = get_tree().get_first_node_in_group("Player")
@onready var HUD: CanvasLayer = get_tree().get_first_node_in_group("HUD")


func _ready() -> void:
	Dialogic.timeline_ended.connect(_on_dialogue_ended)


func _on_body_entered(body: Node2D) -> void:
	if State.has_entered_cave:
		player.can_move = false
		HUD.hide()
		Dialogic.start("has_entered_cave")


func _on_dialogue_ended():
	player.can_move = true
	HUD.show()
