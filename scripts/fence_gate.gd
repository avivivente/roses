extends StaticBody2D

@onready var interaction_area: InteractionArea = $InteractionArea
@onready var collision_shape_2d: CollisionShape2D = $CollisionShape2D
@onready var interaction_collision: CollisionShape2D = $InteractionArea/CollisionShape2D
@onready var animation_player: AnimationPlayer = $AnimationPlayer
@onready var HUD: CanvasLayer = get_tree().get_first_node_in_group("HUD")
@onready var player: CharacterBody2D = get_tree().get_first_node_in_group("Player")

var is_open: bool = false
var player_in_area: bool = false

func _ready():
	if State.has_opened_gate:
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
			HUD.hide()
			player.can_move = false
			interaction_area.set_deferred("monitoring", false)
			Dialogic.start("fence_gate")

func _open_gate():
	if State.has_key1:
		if is_open: return
		
		is_open = true
		collision_shape_2d.set_deferred("disabled", true)
		State.has_opened_gate = true
		interaction_collision.set_deferred("disabled", true)
		player.can_move = true

func dialogue_ended():
	player.can_move = true
	interaction_area.set_deferred("monitoring", true)
	HUD.show()


func _on_interaction_area_body_entered(body: Node2D) -> void:
	if body.is_in_group("Player"):
		player_in_area = true


func _on_interaction_area_body_exited(body: Node2D) -> void:
	if body.is_in_group("Player"):
		player_in_area = false


func _on_dialogic_signal(argument: String):
	if argument == "take_key":
		var fence_key = preload("res://inventory/items/fence_key.tres")
		if player.inv:
			player.inv.remove_item(fence_key, 1)
	if argument == "open_gate":
		animation_player.play("open_gate")
