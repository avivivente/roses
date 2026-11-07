extends CanvasLayer


func _ready() -> void:
	Dialogic.timeline_started.connect(_on_dialogue_started)
	Dialogic.timeline_ended.connect(_on_dialogue_ended)

func _on_dialogue_started() -> void:
	visible = false

func _on_dialogue_ended() -> void:
	visible = true


 
