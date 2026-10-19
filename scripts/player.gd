extends CharacterBody2D

@export var speed: float = 200
@export var run_speed: float = 350

@onready var animated_sprite_2d: AnimatedSprite2D = $AnimatedSprite2D

var animation_direction: String = "down"
var max_health: int
var health: int

func _ready() -> void:
	health = PlayerStats.health
	max_health = PlayerStats.max_health


func _physics_process(_delta: float) -> void:
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

func take_damage(amount: int) -> void:
	health -= amount
	PlayerStats.health = health
	print(health)

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
