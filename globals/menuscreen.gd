extends Node

@onready var button_press: AudioStreamPlayer = $ButtonPress
@onready var button_hover: AudioStreamPlayer = $ButtonHover
@onready var canvas_layer: CanvasLayer = $"."
@onready var canvas_layer_2: CanvasLayer = $CanvasLayer2


func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_cancel"): 
		button_press.play()
		var current_paused = get_tree().paused
		get_tree().paused = not current_paused
		canvas_layer.visible = get_tree().paused


func _on_continue_pressed() -> void:
	button_press.play()
	get_tree().paused = false
	canvas_layer.hide()
func _on_continue_mouse_entered() -> void:
	button_hover.play()


func _on_options_pressed() -> void:
	button_press.play()
func _on_options_mouse_entered() -> void:
	button_hover.play()


func _on_quit_pressed() -> void:
	button_press.play()
	canvas_layer_2.show()
func _on_quit_mouse_entered() -> void:
	button_hover.play()


func _on_yes_pressed() -> void:
	get_tree().paused = false
	button_press.play()
	canvas_layer.hide()
	canvas_layer_2.hide()
	get_tree().change_scene_to_file("res://menu.tscn")
func _on_yes_mouse_entered() -> void:
	button_hover.play()


func _on_no_pressed() -> void:
	button_press.play()
	canvas_layer_2.hide()
func _on_no_mouse_entered() -> void:
	button_hover.play()
