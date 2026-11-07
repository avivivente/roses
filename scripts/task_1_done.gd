extends Area2D

@onready var player: CharacterBody2D = get_tree().get_first_node_in_group("Player")


func _ready() -> void:
	Dialogic.timeline_ended.connect(_on_dialogue_ended)


func _on_body_entered(body: Node2D) -> void:
	State.has_entered_cave = true
	if State.task1_done:
		player.can_move = false

		Dialogic.start("task1done")
	elif Dialogic.VAR.NPCs.has_met_old_lady == false:
		player.can_move = false
		Dialogic.start("talk_to_old_lady")


func _on_dialogue_ended():
	player.can_move = true
