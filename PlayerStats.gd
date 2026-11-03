extends Node

var health: int = 3
var max_health: int = 3

func reset_health() -> void:
	health = max_health
