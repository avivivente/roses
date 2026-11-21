extends Node2D

@onready var animation_player: AnimationPlayer = $AnimationPlayer
@onready var quit: TextureButton = $"../Menuscreen/Control/VBoxContainer/Quit"
@onready var flashbacks: AnimationPlayer = $"../CanvasLayer3/flashbacks"


func _ready() -> void:
	Dialogic.signal_event.connect(on_dialogue_signal)
	quit.hide()
	animation_player.play("leticia_walk_in")
	await animation_player.animation_finished
	Dialogic.start("leticia_walk_in")


func on_dialogue_signal(argument: String):
	if argument == "flashbacks":
		flashbacks.play("flashback")
