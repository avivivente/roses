extends StaticBody2D

@export var item: InvItem

@onready var animation_player: AnimationPlayer = $AnimationPlayer
@onready var interaction_area: InteractionArea = $InteractionArea
@onready var player: CharacterBody2D = get_tree().get_first_node_in_group("Player") 

var is_open: bool = false
var player_in_area: bool = false

func _ready():
	interaction_area.interact = Callable(self, "_open_chest")

func _process(delta):
	if player_in_area:
		if Input.is_action_just_pressed("interact"):
			if State.has_key1:
				start_dialogue()
			else:
				start_dialogue()
				collect_key()

func _open_chest():
	if is_open: return
	
	is_open = true
	animation_player.play("open")

func collect_key():
	player.collect(item)
	State.has_key1 = true

func _on_interaction_area_body_entered(body: Node2D) -> void:
	if body.is_in_group("Player"):
		player_in_area = true

func _on_interaction_area_body_exited(body: Node2D) -> void:
	if body.is_in_group("Player"):
		player_in_area = false
	if is_open and body.name == "Player":
		is_open = false
		animation_player.play_backwards("open")


func start_dialogue():
	Dialogic.timeline_ended.connect(dialogue_ended)
	Dialogic.start("key_chest")
	player.can_move = false
	interaction_area.set_deferred("monitoring", false)
	animation_player.play("open")

func dialogue_ended():
	Dialogic.timeline_ended.disconnect(dialogue_ended)
	player.can_move = true
	interaction_area.set_deferred("monitoring", true)
	animation_player.play_backwards("open")
