extends Resource

class_name PlayerData

@export var speed: float = 250
@export var run_speed: float = 450
@export var health: int = 3
@export var max_health: int = 3

@export var save_position : Vector2

func change_health(value: int):
	health += value

func update_pos(value : Vector2):
	save_position = value

func reset_health() -> void:
	health = max_health
