extends CanvasLayer

@onready var canvas_layer: CanvasLayer = $"."


func _ready() -> void:
	visible = false


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func _on_back_pressed() -> void:
	visible = false


func _on_back_mouse_entered() -> void:
	pass # Replace with function body.
