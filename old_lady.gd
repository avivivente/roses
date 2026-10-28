extends Node2D

@onready var canvas_layer: CanvasLayer = $"../CanvasLayer"

var player_in_area: bool = false

func _on_task_1_body_entered(body: Node2D) -> void:
	if body.is_in_group("Player"): 
		player_in_area = true

func _on_task_1_body_exited(body: Node2D) -> void:
	if body.is_in_group("Player"):
		player_in_area = false

func _unhandled_input(event: InputEvent) -> void:
	if player_in_area and Input.is_action_just_pressed("interact"):
		canvas_layer.hide()
		Dialogic.timeline_ended.connect(_on_timeline_ended)
		Dialogic.start("task1")
   
func _on_timeline_ended():
	Dialogic.timeline_ended.disconnect(_on_timeline_ended)
	canvas_layer.show()
