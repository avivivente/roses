extends Sprite2D

@onready var animation_player: AnimationPlayer = $AnimationPlayer
@onready var leticia: CharacterBody2D = $"../Leticia"
@onready var player_cam: Camera2D = $"../Leticia/Camera2D"
@onready var killer_cam: Camera2D = $Camera2D
@onready var fade: AnimationPlayer = $"../CanvasLayer2/FadeOverlay/AnimationPlayer"

func _ready() -> void:
	Dialogic.signal_event.connect(on_dialogue_signal)

func _on_area_2d_body_entered(body: Node2D) -> void:
	leticia.can_move = false
	player_cam.set_deferred("enabled", false)
	killer_cam.set_deferred("enabled", true)
	Dialogic.start("killer")


func on_dialogue_signal(argument: String):
	if argument == "leticia_walk_in":
		animation_player.play("approach_killer")
		await animation_player.animation_finished
	if argument == "leticia_idle":
		animation_player.play("leticia_idle")
	if argument == "look_at_leticia":
		animation_player.stop()
		animation_player.play("idle_left")
	if argument == "get_in_car":
		animation_player.stop()
		animation_player.play("get_in_car")
		await animation_player.animation_finished
		fade.play("fade_to_black")
		await fade.animation_finished
		State.end_credits = true
		get_tree().change_scene_to_file("res://scene/chapter.tscn")
