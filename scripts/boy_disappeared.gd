extends Area2D

@onready var leticia: CharacterBody2D = $"../Leticia"
@onready var fade: AnimationPlayer = $"../CanvasLayer2/FadeOverlay/AnimationPlayer"

var has_triggered: bool = false

func _on_body_entered(body: Node2D) -> void:
	if has_triggered:
		return
		
	if body.is_in_group("Player") and State.has_rose:
		has_triggered = true
		leticia.can_move = false
		
		Dialogic.timeline_ended.connect(on_dialogue_ended, CONNECT_ONE_SHOT)
		Dialogic.start("boy_disappeared")

func on_dialogue_ended() -> void:
	set_deferred("monitoring", false)
	leticia.can_move = true
