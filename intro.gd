extends Node

@onready var animation_player: AnimationPlayer = $"../CanvasLayer/FadeOverlay/AnimationPlayer"
@onready var leticia: CharacterBody2D = $"../Leticia"
@onready var hud: StaticBody2D = $"../CanvasLayer/HUD"
@onready var hearts_container: HBoxContainer = $"../CanvasLayer/HeartsContainer"
@onready var dialogue_actionable_2d: DialogueActionable2D = $DialogueActionable2D



func _on_dialogue_actionable_2d_body_entered(body: Node2D) -> void:
	await animation_player.animation_finished
