extends StaticBody2D

@onready var interaction_area: InteractionArea = $InteractionArea
@onready var collision_shape_2d: CollisionShape2D = $CollisionShape2D
@onready var animation_player: AnimationPlayer = $AnimationPlayer

var is_open: bool = false
var player_in_area: bool = false

func _ready():
	interaction_area.interact = Callable(self, "_open_gate")

func _process(delta):
	if player_in_area:
		if Input.is_action_just_pressed("interact"):
			Dialogic.start("fence_gate")


func _open_gate():
	if State.has_key:
		if is_open: return
		
		is_open = true
		animation_player.play("open_gate")
		collision_shape_2d.set_deferred("disabled", true)

func _on_interaction_area_body_entered(body: Node2D) -> void:
	if body.is_in_group("Player"):
		player_in_area = true


func _on_interaction_area_body_exited(body: Node2D) -> void:
	if body.is_in_group("Player"):
		player_in_area = false
