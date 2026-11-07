extends Area2D

@onready var leticia: CharacterBody2D = $"../Leticia"
@onready var pan_camera: AnimationPlayer = $"../Leticia/pan_camera"
@onready var intro: Area2D = $"."
@onready var fade: AnimationPlayer = $"../CanvasLayer2/FadeOverlay/AnimationPlayer"
@onready var canvas_layer: CanvasLayer = $"../CanvasLayer"


func _ready() -> void:
	Dialogic.signal_event.connect(_on_dialogic_signal)

func _on_body_entered(body: Node2D) -> void:
	if State.has_triggered_intro:
		intro.set_deferred("monitoring", false)
		intro.set_deferred("monitorable", false)
	else:
		canvas_layer.hide()
		State.has_triggered_intro = true
		fade.play("fade_to_normal")
		await fade.animation_finished
		if body.is_in_group("Player"):
			Dialogic.start("intro")

### Signals

func _on_dialogic_signal(argument: String):
	if argument == "pan_camera":
		pan_camera.play("pan_camera")
		await pan_camera.animation_finished

	if argument == "end":
		intro.set_deferred("monitoring", false)
		intro.set_deferred("monitorable", false)
		leticia.can_move = true
		State.task0_active = true
