extends StaticBody2D

@onready var player: CharacterBody2D = get_tree().get_first_node_in_group("Player")
@onready var animation_player: AnimationPlayer = $AnimationPlayer

var player_in_area: bool = false


func _ready() -> void:
	Dialogic.signal_event.connect(_on_dialogic_signal)
	Dialogic.timeline_ended.connect(_on_dialogue_ended)


func _process(delta):
	if player_in_area:
		if Input.is_action_just_pressed("interact"):
			start_dialogue()


func _on_interaction_area_body_entered(body: Node2D) -> void:
	player_in_area = true


func _on_interaction_area_body_exited(body: Node2D) -> void:
	player_in_area = false


func start_dialogue():
	player.can_move = false
	Dialogic.start("itwasntyourfault")


func _on_dialogue_ended():
	player.can_move = true


func _on_dialogic_signal(argument: String):
	if argument == "jumpscare":
		animation_player.play("jumpscare")
