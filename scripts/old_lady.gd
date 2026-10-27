extends Node2D

@onready var hud: StaticBody2D = $"../CanvasLayer/HUD"
@onready var hearts_container: HBoxContainer = $"../CanvasLayer/HeartsContainer"


func _on_dialogue_actionable_2d_actioned() -> void:
	hud.hide()
	hearts_container.hide()
	DialogueManager.show_dialogue_balloon(load("res://task.dialogue"), "task1")


func _on_dialogue_actionable_2d_dialogue_ended() -> void:
	hud.show()
	hearts_container.show()
