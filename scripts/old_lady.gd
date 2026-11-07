extends CharacterBody2D

@export var item: InvItem

@onready var animation_player: AnimationPlayer = $AnimationPlayer
@onready var interaction_area: InteractionArea = $InteractionArea
@onready var leticia: CharacterBody2D = $"../Leticia"

var player_in_area: bool = false

func _ready() -> void:
	Dialogic.signal_event.connect(_on_dialogic_signal)
	if Dialogic.VAR.tasks.task1:
		animation_player.play("idle_down")
	elif Dialogic.VAR.tasks.task1_done:
		animation_player.play("idle_down")
	else:
		animation_player.play("rummage")

func _on_task_1_body_entered(body: Node2D) -> void:
	if body.is_in_group("Player"): 
		player_in_area = true

func _on_task_1_body_exited(body: Node2D) -> void:
	if body.is_in_group("Player"):
		player_in_area = false

func _unhandled_input(event: InputEvent) -> void:
	if player_in_area and Input.is_action_just_pressed("interact"):
		State.task0_active = false
		leticia.can_move = false
		interaction_area.set_deferred("monitoring", false)
		Dialogic.timeline_ended.connect(_on_timeline_ended)
		Dialogic.start("task1")
   
func _on_timeline_ended():
	Dialogic.timeline_ended.disconnect(_on_timeline_ended)
	leticia.can_move = true
	interaction_area.set_deferred("monitoring", true)

func _on_dialogic_signal(argument: String):
	if argument == "rummage":
		animation_player.stop()
		animation_player.play("rummage")
	if argument == ("old_lady_idle_right"):
		animation_player.stop()
		animation_player.play("idle_right")
	if argument == ("old_lady_idle_down"):
		animation_player.stop()
		animation_player.play("idle_down")
	if argument == "take_rose":
		var rose = preload("res://inventory/items/rose.tres")
		if leticia.inv:
			leticia.inv.remove_item(rose, 1)
		State.task1_done = true
	if argument == "give_key":
		leticia.collect(item)
		State.has_area2_key = true
