extends CharacterBody2D

signal healthChanged
signal died

@export var speed: float = 200
@export var run_speed: float = 350

@onready var animation_player: AnimationPlayer = $AnimationPlayer
@onready var damage_cooldown: Timer = $DamageCooldown
@onready var taking_damage: AudioStreamPlayer2D = $TakingDamage
@onready var you_died: AudioStreamPlayer2D = $YouDied
@onready var effects: AnimationPlayer = $Effects
@onready var hurtblinktimer: Timer = $HurtBlinkTimer
@onready var actionable_finder: Area2D = $DialogueMarker2D/ActionableFinder


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

func _unhandled_input(event: InputEvent) -> void:
	if Input.is_action_just_pressed("interact"):
		var actionables = actionable_finder.get_overlapping_areas()
		if actionables.size() > 0:
			actionables[0].action()
			return


func _physics_process(_delta: float) -> void:
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
		# Make player invincible for a short time
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
