extends CharacterBody2D

@export var MovementScript: Script
@onready var animated_sprite_2d: AnimatedSprite2D = $AnimatedSprite2D
@onready var attack_timer: Timer = $AttackTimer

var is_alive: bool = true
var strength: int = 10
var target_in_range: bool = false
var target = null

func _physics_process(delta):
	if velocity.length() > 0:
		animated_sprite_2d.play("walk")
	else:
		animated_sprite_2d.play("idle")

func _on_follow_area_body_entered(body: Node2D) -> void:
	if body.name == "Player":
		target = body

func _on_hitbox_body_entered(body: Node2D) -> void:
	if body.name == "Player":
		target_in_range = true
		body.take_damage(strength)
		attack_timer.start()


func _on_hitbox_body_exited(body: Node2D) -> void:
	if body.name == "Player" and is_alive:
		target_in_range = false
		attack_timer.stop()


func _on_attack_timer_timeout() -> void:
	if target and target_in_range:
		target.take_damage(strength)
