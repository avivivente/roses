extends Area2D

@onready var animation_player: AnimationPlayer = $"../CanvasLayer/Control/AnimationPlayer"
@onready var shift_to_run: Area2D = $"."


func _on_body_entered(body: Node2D) -> void:
	if body.is_in_group("Player"):
		if not State.has_entered_cave:
			State.has_entered_cave = true
			print("Leticia has entered cave!")
			animation_player.play("ShiftToRun")
			
			await animation_player.animation_finished
		else:
			print("Already triggered the animation")
			play_once()

func play_once():
	shift_to_run.set_deferred("monitoring", false)
