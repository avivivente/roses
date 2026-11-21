extends Node2D

@onready var animation_player: AnimationPlayer = $AnimationPlayer
@onready var quit: TextureButton = $"../Menuscreen/Control/VBoxContainer/Quit"


func _ready() -> void:
	quit.hide()
	animation_player.play("leticia_walk_in")
	await animation_player.animation_finished
	Dialogic.start("leticia_walk_in")
