extends Panel

@onready var splashscreen: AnimationPlayer = $"../Sprite2D/AnimationPlayer"


func _ready() -> void:
	splashscreen.play("splashscreen")
	await splashscreen.animation_finished
	
	get_tree().change_scene_to_file("res://menu.tscn")
