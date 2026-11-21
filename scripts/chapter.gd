extends CanvasLayer

@onready var chapter: RichTextLabel = $RichTextLabel
@onready var sfx: AudioStreamPlayer = $AudioStreamPlayer

func _ready() -> void:
	sfx.play()
	if State.start_game:
		chapter.text = "CHAPTER 1 - ROSES"
	elif State.area2_gate_opened:
		chapter.text = "CHAPTER 2 - MEMORIES"
	elif State.end_credits:
		chapter.text = "FIN - LETICIA'S END"

func _on_timer_timeout() -> void:
	if State.start_game:
		get_tree().change_scene_to_file("res://levels/base_level.tscn")
	elif State.area2_gate_opened:
		get_tree().change_scene_to_file("res://levels/area_2.tscn")
	elif State.end_credits:
		get_tree().change_scene_to_file("res://levels/ending.tscn")
