extends CanvasLayer

const continue_normal = preload("res://assets/UI/Continue.png")
const continue_pressed = preload("res://assets/UI/Continue_Pressed.png")
const continue_hover = preload("res://assets/UI/Continue_Hover.png")

@onready var animation_player: AnimationPlayer = $FadeOverlay/AnimationPlayer
@onready var button_press: AudioStreamPlayer = $Button_press
@onready var button_hover: AudioStreamPlayer = $Button_hover
@onready var are_you_sure: CanvasLayer = $CanvasLayer2
@onready var start: TextureButton = $ButtonManager/VBoxContainer/Start
@onready var start_new_game: CanvasLayer = $CanvasLayer3
@onready var title: TextureRect = $Title
@onready var button_manager: Control = $ButtonManager
@onready var options: CanvasLayer = $Options
@onready var titlemusic: AudioStreamPlayer = $AudioStreamPlayer
@onready var fade_overlay: ColorRect = $FadeOverlay
@onready var new_game: TextureButton = $ButtonManager/VBoxContainer/NewGame

var button_type = null

func _ready() -> void:
	if State.start_game:
		new_game.show()
		start.texture_normal = continue_normal
		start.texture_pressed = continue_pressed
		start.texture_hover = continue_hover
		button_type = "continue"
	elif State.end_credits:
		new_game.show()
		button_type = "start"
	else:
		button_type = "start"
		new_game.hide()
	
	animation_player.play("fade_to_normal")
	await animation_player.animation_finished
	fade_overlay.hide()
	titlemusic.play()
	
	options.options_closed.connect(options_close)

func _on_start_pressed() -> void:
	button_press.play()
	$FadeOverlay.show()
	$FadeOverlay/fade_timer.start()
	animation_player.play("fade_to_black")
	State.start_game = true


func _on_start_mouse_entered() -> void:
	button_hover.play()


func _on_quit_pressed() -> void:
	button_press.play()
	title.hide()
	button_manager.hide()
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
	title.show()
	button_manager.show()
func _on_no_mouse_entered() -> void:
	button_hover.play()


func _on_fade_timer_timeout() -> void:
	if button_type == "start":
		print("Button is a Start button")
		get_tree().change_scene_to_file("res://scene/chapter.tscn")
	elif button_type == "continue":
		print("Button is a Continue button")
		get_tree().change_scene_to_file("res://levels/base_level.tscn")


func _on_options_pressed() -> void:
	button_press.play()
	title.hide()
	button_manager.hide()
	options.show()
func _on_options_mouse_entered() -> void:
	button_hover.play() 

func options_close():
	title.show()
	button_manager.show()


func _on_new_game_pressed() -> void:
	button_press.play()
	start_new_game.show()
func _on_new_game_mouse_entered() -> void:
	button_hover.play()


func _on_yes_1_pressed() -> void:
	button_press.play()
	start_new_game.hide()
	State.reset()
	PlayerStats.reset_health()
	Dialogic.clear()
	button_type = "start"
	_on_start_pressed()
func _on_yes_1_mouse_entered() -> void:
	button_hover.play()


func _on_no_1_pressed() -> void:
	button_press.play()
	start_new_game.hide()
func _on_no_1_mouse_entered() -> void:
	button_hover.play()
