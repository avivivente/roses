extends Area2D

@onready var no_return: CanvasLayer = $"../../NoReturn"
@onready var player: CharacterBody2D = get_tree().get_first_node_in_group("Player")
@onready var ambience: AudioStreamPlayer = $Ambience


func _ready() -> void:
	no_return.hide()

func _on_body_entered(body: Node2D) -> void:
	if body == player:
		no_return.show()
	if no_return.visible:
		player.can_move = false
	else:
		player.can_move = true

func _on_yes_pressed() -> void:
	get_tree().change_scene_to_file("res://scene/chapter.tscn")

func _on_no_pressed() -> void:
	player.can_move = true
	no_return.hide()
