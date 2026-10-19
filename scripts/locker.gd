extends Area2D

@export var player: CharacterBody2D

@onready var interaction_area: Area2D = $InteractionArea
@onready var exit_point: Marker2D = $ExitPoint
@onready var sprite: Sprite2D = $Sprite2D

var player_nearby: bool = false
var player_hidden: bool = false

func _ready() -> void:
	interaction_area.body_entered.connect(_on_body_entered)
	interaction_area.body_exited.connect(_on_body_exited)


func _process(_delta: float) -> void:
	if not is_instance_valid(player):
		return

	if Input.is_action_just_pressed("interact"):
		if player_hidden:
			exit_locker()
		elif player_nearby:
			enter_locker()


func enter_locker() -> void:
	if not is_instance_valid(player):
		return

	player_hidden = true
	player.add_to_group("hidden")

	# Stop the player and hide their character.
	player.velocity = Vector2.ZERO
	player.set_physics_process(false)
	player.visible = false
	$Sprite2D.texture=ResourceLoader.load("res://assets/interactables/locker_hidden.png")

func exit_locker() -> void:
	if not is_instance_valid(player):
		return

	# Move the player to the exit marker.
	player.global_position = exit_point.global_position
	player.force_update_transform()

	player.visible = true
	player.set_physics_process(true)
	player.remove_from_group("hidden")

	player_hidden = false
	$Sprite2D.texture=ResourceLoader.load("res://assets/interactables/locker.png")

func _on_body_entered(body: Node2D) -> void:
	if body == player:
		player_nearby = true

func _on_body_exited(body: Node2D) -> void:
	if body == player and not player_hidden:
		player_nearby = false
