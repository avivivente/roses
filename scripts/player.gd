extends CharacterBody2D

signal healthChanged
signal died

@export var speed: float = 200
@export var run_speed: float = 350

@onready var animated_sprite_2d: AnimatedSprite2D = $AnimatedSprite2D
@onready var damage_cooldown: Timer = $DamageCooldown
@onready var taking_damage: AudioStreamPlayer2D = $TakingDamage
@onready var you_died: AudioStreamPlayer2D = $YouDied
@onready var effects: AnimationPlayer = $Effects
@onready var hurtblinktimer: Timer = $HurtBlinkTimer


var animation_direction: String = "down"
var alive: bool = true
var max_health: int 
var health: int 


var look_dir: String = "up"
var can_move: bool = true

func _ready() -> void:
	add_to_group("Player")
	
	health = PlayerStats.health
	max_health = PlayerStats.max_health
	effects.play("RESET")
	
	NavigationManager.on_trigger_player_spawn.connect(_on_spawn)


func _physics_process(_delta: float) -> void:
	if !can_move:
		animated_sprite_2d.play("idle_" + animation_direction)
		return

	if alive:
		var direction := Input.get_vector("left", "right", "up", "down")

		update_sprite_direction(direction)

		# Hold Shift to run.
		var current_speed = speed

		if Input.is_action_pressed("run"):
			current_speed = run_speed

		if direction == Vector2.ZERO:
			animated_sprite_2d.play("idle_" + animation_direction)
			velocity = Vector2.ZERO
		else:
			animated_sprite_2d.play("walk_" + animation_direction)
			velocity = direction * current_speed

		move_and_collide(velocity * _delta)



func _on_spawn(position: Vector2, direction: String):
	global_position = position
	animated_sprite_2d.play("walk_" + direction)
	animated_sprite_2d.stop()


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
		# Make player invincible for a short time
		damage_cooldown.start()

func die() -> void:
	animated_sprite_2d.play("death")
	you_died.play()
	alive = false
	await animated_sprite_2d.animation_finished
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
