extends Area2D

@onready var player: CharacterBody2D = get_tree().get_first_node_in_group("Player")

func ready():
	Dialogic.timeline_started.connect(on_dialogue_started)

func _on_body_entered(body: Node2D) -> void:
	player.can_move = false
	Dialogic.start("no_going_back")
	Dialogic.timeline_ended.connect(on_dialogue_ended)

func on_dialogue_started():
	player.can_move = false 

func on_dialogue_ended():
	player.can_move = true
