extends Node2D

@onready var hud: StaticBody2D = $"../CanvasLayer/HUD"
@onready var hearts_container: HBoxContainer = $"../CanvasLayer/HeartsContainer"


func _on_dialogue_state_context_property_list_changed() -> void:
	pass # Replace with function body.

func _on_dialogue_actionable_2d_actioned() -> void:
	hud.hide()
	hearts_container.hide()

func _on_dialogue_actionable_2d_dialogue_ended() -> void:
	hud.show()
	hearts_container.show()
