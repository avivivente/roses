extends CharacterBody2D

@export var MovementScript: Script
@onready var animated_sprite_2d: AnimatedSprite2D = $AnimatedSprite2D
@onready var attack_timer: Timer = $AttackTimer
@onready var attack_sound: AudioStreamPlayer2D = $AttackSound
@onready var proximity: AudioStreamPlayer2D = $Proximity



var animation_direction: String = "down"
var is_alive: bool = true
var strength: int = 1
var target_in_range: bool = false
var target = null


func _physics_process(delta):
	if velocity.length() > 0:
		animated_sprite_2d.play("walk_down")
	else:
		animated_sprite_2d.play("idle_down")

func _on_follow_area_body_entered(body: Node2D) -> void:
	if body.name == "Leticia":
		target = body


func _on_hitbox_body_entered(body: Node2D) -> void:
	if body.name == "Leticia":
		target_in_range = true
		attack_sound.play()
		body.take_damage(strength)
		attack_timer.start()


func _on_hitbox_body_exited(body: Node2D) -> void:
	if body.name == "Leticia" and is_alive:
		target_in_range = false
		attack_timer.stop()


func _on_attack_timer_timeout() -> void:
	if target and target_in_range:
		target.take_damage(strength)
		attack_sound.play()


func _on_proximity_area_body_entered(body: Node2D) -> void:
	$Proximity.play()
