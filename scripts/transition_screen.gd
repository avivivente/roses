extends CanvasLayer

signal on_transition_finished

@onready var fade_overlay: ColorRect = $FadeOverlay
@onready var animation_player: AnimationPlayer = $AnimationPlayer


func _ready() -> void:
	fade_overlay.visible = false
	animation_player.animation_finished.connect(_on_animation_finished)

func _on_animation_finished(anim_name):
	if anim_name == "fade_to_black":
		on_transition_finished.emit()
		animation_player.play("fade_to_normal")
	elif anim_name == "fade_to_normal":
		fade_overlay.visible = false

func transition():
	fade_overlay.visible = true
	animation_player.play("fade_to_black")
