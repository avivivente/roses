extends CanvasLayer

@onready var chapter: RichTextLabel = $RichTextLabel
@onready var sfx: AudioStreamPlayer = $AudioStreamPlayer

var next_scene: String = ""

func _ready() -> void:
	sfx.play()
	
	if State.end_credits:
		chapter.text = "FIN - LETICIA'S END"
		next_scene = "res://levels/ending.tscn"
	elif State.area2_gate_opened:
		chapter.text = "CHAPTER 2 - MEMORIES"
		next_scene = "res://levels/area_2.tscn"
	elif State.start_game:
		chapter.text = "CHAPTER 1 - ROSES"
		next_scene = "res://levels/base_level.tscn"

func _on_timer_timeout() -> void:
	if next_scene != "":
		get_tree().change_scene_to_file(next_scene)
