extends Area2D

@export var player: CharacterBody2D

@onready var interaction_area: Area2D = $InteractionArea
@onready var exit_point: Marker2D = $ExitPoint
@onready var sprite: Sprite2D = $Sprite2D
@onready var point_light_2d: PointLight2D = $PointLight2D
@onready var locker_enter: AudioStreamPlayer2D = $LockerEnter
@onready var locker_exit: AudioStreamPlayer2D = $LockerExit


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
	locker_enter.play()
	$Sprite2D.texture=ResourceLoader.load("res://assets/interactables/locker_hidden.png")
	point_light_2d.visible = true
	point_light_2d.energy = 0.7
	$E_TO_ENTER

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
	locker_exit.play()
	$Sprite2D.texture=ResourceLoader.load("res://assets/interactables/locker.png")
	point_light_2d.visible = false
	point_light_2d.energy = 0

func _on_body_entered(body: Node2D) -> void:
	if body == player:
		player_nearby = true

func _on_body_exited(body: Node2D) -> void:
	if body == player and not player_hidden:
		player_nearby = false
