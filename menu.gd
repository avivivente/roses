extends Node2D

@onready var animation_player: AnimationPlayer = $CanvasLayer/FadeOverlay/AnimationPlayer
@onready var button_press: AudioStreamPlayer2D = $CanvasLayer/Button_press
@onready var button_hover: AudioStreamPlayer2D = $CanvasLayer/Button_hover
@onready var are_you_sure: Control = $CanvasLayer/AreYouSure
@onready var popup_sound: AudioStreamPlayer2D = $CanvasLayer/AreYouSure/PopupSound


var button_type = null

func _on_start_pressed() -> void:
	button_press.play()
	button_type = "start"
	$CanvasLayer/FadeOverlay.show()
	$CanvasLayer/FadeOverlay/fade_timer.start()
	animation_player.play("fade_to_black")
func _on_start_mouse_entered() -> void:
	button_hover.play()

func _on_continue_pressed() -> void:
	button_press.play()
func _on_continue_mouse_entered() -> void:
	button_hover.play()


func _on_options_pressed() -> void:
	button_press.play()
func _on_options_mouse_entered() -> void:
	button_hover.play()


func _on_quit_pressed() -> void:
	popup_sound.play()
	are_you_sure.show()
func _on_quit_mouse_entered() -> void:
	button_hover.play()


func _on_yes_pressed() -> void:
	button_press.play()
	get_tree().quit()
func _on_yes_mouse_entered() -> void:
	button_hover.play()


func _on_no_pressed() -> void:
	button_press.play()
	are_you_sure.hide()
func _on_no_mouse_entered() -> void:
	button_hover.play()


func _on_fade_timer_timeout() -> void:
	if button_type == "start":
		get_tree().change_scene_to_file("res://levels/base_level.tscn")
