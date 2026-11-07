extends StaticBody2D

@onready var interaction_area: InteractionArea = $InteractionArea
@onready var collision_shape_2d: CollisionShape2D = $CollisionShape2D
@onready var interaction_collision: CollisionShape2D = $InteractionArea/CollisionShape2D
@onready var animation_player: AnimationPlayer = $AnimationPlayer
@onready var player: CharacterBody2D = get_tree().get_first_node_in_group("Player")

var is_open: bool = false
var player_in_area: bool = false

func _ready():
	if State.area2_gate_opened:
		animation_player.play("has_opened_gate")
		interaction_collision.set_deferred("disabled", true)
		collision_shape_2d.set_deferred("disabled", true)
	else:
		Dialogic.signal_event.connect(_on_dialogic_signal)
		Dialogic.timeline_ended.connect(dialogue_ended)
		interaction_area.interact = Callable(self, "_open_gate")

func _process(delta):
	if player_in_area:
		if Input.is_action_just_pressed("interact"):
			player.can_move = false
			interaction_area.set_deferred("monitoring", false)
			Dialogic.start("area2_gate")

func _open_gate():
	if State.has_area2_key:
		if is_open: return
		
		is_open = true
		collision_shape_2d.set_deferred("disabled", true)
		State.has_opened_gate = true
		interaction_collision.set_deferred("disabled", true)
		player.can_move = true

func dialogue_ended():
	player.can_move = true
	interaction_area.set_deferred("monitoring", true)



func _on_interaction_area_body_entered(body: Node2D) -> void:
	if body.is_in_group("Player"):
		player_in_area = true


func _on_interaction_area_body_exited(body: Node2D) -> void:
	if body.is_in_group("Player"):
		player_in_area = false


func _on_dialogic_signal(argument: String):
	if argument == "take_area2_key":
		var fence_key = preload("res://inventory/items/fence_key.tres")
		if player.inv:
			player.inv.remove_item(fence_key, 1)
	if argument == "open_area2":
		animation_player.play("open_gate")
