extends CharacterBody2D

signal healthChanged
signal died

var save_file_path = "user://save/"
var save_file_name = "PlayerSave.tres"


@export var speed: float = 250
@export var run_speed: float = 450

@export var inv: Inv

@onready var animation_player: AnimationPlayer = $AnimationPlayer
@onready var damage_cooldown: Timer = $DamageCooldown
@onready var taking_damage: AudioStreamPlayer2D = $TakingDamage
@onready var you_died: AudioStreamPlayer2D = $YouDied
@onready var effects: AnimationPlayer = $Effects
@onready var hurtblinktimer: Timer = $HurtBlinkTimer
@onready var pickup_area: Area2D = $pickup_area
@onready var collision_shape_2d: CollisionShape2D = $CollisionShape2D


var animation_direction: String = "down"
var alive: bool = true
var max_health: int 
var health: int 


var look_dir: String = "up"
var can_move: bool = true
var look_around: bool = false
var look_left: bool = false


func _ready() -> void:
	Dialogic.signal_event.connect(_on_dialogic_signal)
	
	add_to_group("Player")
	
	health = PlayerStats.health
	max_health = PlayerStats.max_health
	effects.play("RESET")
	
	NavigationManager.on_trigger_player_spawn.connect(_on_spawn)


func _process(delta: float) -> void:
	if is_in_group("hidden"):
		collision_shape_2d.set_deferred("disabled", true)
	else:
		collision_shape_2d.set_deferred("disabled", false)


func _physics_process(_delta: float) -> void:
	if look_around:
		return
	
	if look_left:
		return
	
	if !can_move:
		animation_player.play("idle_" + animation_direction)
		return

	if alive:
		var direction := Input.get_vector("left", "right", "up", "down")
		update_sprite_direction(direction)

		if direction == Vector2.ZERO:
			velocity = Vector2.ZERO
			animation_player.play("idle_" + animation_direction)
		else:
			if Input.is_action_pressed("run"):
				velocity = direction * run_speed
				animation_player.play("run_" + animation_direction)
			else:
				velocity = direction * speed
				animation_player.play("walk_" + animation_direction)

		move_and_collide(velocity * _delta)


func _on_spawn(position: Vector2, direction: String):
	global_position = position
	animation_player.play("walk_" + direction)
	animation_player.stop()


func take_damage(amount: int) -> void:
	if alive:
		if damage_cooldown.time_left > 0:
			return
			
		taking_damage.play()
		health -= amount
		PlayerStats.health = health
		healthChanged.emit(health)
		print(health)
		effects.play("hurtBlink")
		hurtblinktimer.start()
		await hurtblinktimer.timeout
		effects.play("RESET")
		if health <= 0:
			die()
			
			print("You Died!")
		damage_cooldown.start()

func die() -> void:
	animation_player.play("death")
	you_died.play()
	alive = false
	await animation_player.animation_finished
	died.emit()


func update_sprite_direction(input: Vector2) -> void:
	if input == Vector2.ZERO:
		return

	if abs(input.x) > abs(input.y):
		if input.x < 0:
			animation_direction = "left"
		else:
			animation_direction = "right"
	else:
		if input.y < 0:
			animation_direction = "up"
		else:
			animation_direction = "down"


func _on_dialogic_signal(argument: String):
	if argument == "look_around":
		can_move = false
		look_around = true
		velocity = Vector2.ZERO
		animation_player.play("look_around")
		await animation_player.animation_finished
		look_around = false
	if argument == "look_left":
		can_move = false
		look_left = true
		velocity = Vector2.ZERO
		animation_player.play("left")
		await animation_player.animation_finished
		look_left = false

func collect(item):
	inv.insert(item)
