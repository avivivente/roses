extends CharacterBody2D

@onready var interaction_area: InteractionArea = $InteractionArea
@onready var leticia: CharacterBody2D = get_tree().get_first_node_in_group("Player")
@onready var animation_player: AnimationPlayer = $AnimationPlayer
@onready var area_2d: Area2D = $Area2D
@onready var boy: CharacterBody2D = $"."
@onready var collision_shape_2d: CollisionShape2D = $CollisionShape2D


var player_in_area: bool = false

func _ready() -> void:
	Dialogic.signal_event.connect(_on_dialogic_signal)
	Dialogic.timeline_ended.connect(on_dialogue_ended)

func _process(delta: float) -> void:
	if State.has_rose:
		boy.visible = false
		collision_shape_2d.set_deferred("disabled", true)
		interaction_area.set_deferred("monitoring", false)


func _unhandled_input(event: InputEvent) -> void:
	if player_in_area and Input.is_action_just_pressed("interact"):
		leticia.can_move = false
		interaction_area.set_deferred("monitoring", false)
		
		Dialogic.timeline_ended.connect(_on_timeline_ended)
		Dialogic.start("boy")
   

func _on_timeline_ended():
	Dialogic.timeline_ended.disconnect(_on_timeline_ended)
	leticia.can_move = true
	interaction_area.set_deferred("monitoring", true)


func face_player(player_position: Vector2):
	var direction: Vector2 = (player_position - global_position).normalized()
	
	if abs(direction.x) > abs(direction.y):
		if direction.x > 0:
			animation_player.play("idle_right")
		else:
			animation_player.play("idle_left") 
	else:
		if direction.y > 0:
			animation_player.play("idle_down")
		else:
			animation_player.play("idle_up")


func _on_dialogic_signal(argument: String):
	if argument == "face_player":
		face_player(leticia.global_position)


func on_dialogue_ended():
	animation_player.play("idle_down")
	leticia.can_move = true


func _on_area_2d_body_entered(body: Node2D) -> void:
	if not Dialogic.VAR.NPCs.has_met_boy:
		leticia.can_move = false
		Dialogic.start("boy")
	else:
		area_2d.set_deferred("monitoring", false)


func _on_interaction_area_body_entered(body: Node2D) -> void:
	player_in_area = true


func _on_interaction_area_body_exited(body: Node2D) -> void:
	player_in_area = false
