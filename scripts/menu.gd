extends CanvasLayer

@onready var animation_player: AnimationPlayer = $FadeOverlay/AnimationPlayer
@onready var button_press: AudioStreamPlayer2D = $Button_press
@onready var button_hover: AudioStreamPlayer2D = $Button_hover
@onready var canvas_layer_2: CanvasLayer = $CanvasLayer2


var button_type = null

func _on_start_pressed() -> void:
	button_press.play()
	button_type = "start"
	$FadeOverlay.show()
	$FadeOverlay/fade_timer.start()
	animation_player.play("fade_to_black")


func _on_start_mouse_entered() -> void:
	button_hover.play()


func _on_quit_pressed() -> void:
	button_press.play()
	canvas_layer_2.show()
func _on_quit_mouse_entered() -> void:
	button_hover.play()


func _on_yes_pressed() -> void:
	button_press.play()
	get_tree().quit()
func _on_yes_mouse_entered() -> void:
	button_hover.play()


func _on_no_pressed() -> void:
	button_press.play()
	canvas_layer_2.hide()
func _on_no_mouse_entered() -> void:
	button_hover.play()


func _on_fade_timer_timeout() -> void:
	if button_type == "start":
		get_tree().change_scene_to_file("res://levels/base_level.tscn")


func _on_options_pressed() -> void:
	button_press.play()
func _on_options_mouse_entered() -> void:
	button_hover.play()
