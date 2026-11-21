extends CanvasModulate



func _ready() -> void:
	hide()
	
	if State.has_key1:
		show()
