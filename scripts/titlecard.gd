extends Node

@onready var animation_player: AnimationPlayer = $CanvasLayer2/StaticBody2D/AnimationPlayer
@onready var animated_sprite_2d: AnimatedSprite2D = $Player/AnimatedSprite2D
@onready var HeartsContainer: HBoxContainer = $CanvasLayer/HeartsContainer
@onready var player: CharacterBody2D = $Player
@onready var animation_player1: AnimationPlayer = $AnimationPlayer
@onready var hud: StaticBody2D = $CanvasLayer/HUD
@onready var animation_player2: AnimationPlayer = $".."
@onready var sprite_2d: Sprite2D = $Sprite2D

func _ready():
	
	hud.hide()
	$Player.hide()
	
	
	animation_player.play("fade")
	animation_player2.play("IntroScene")
	
	
	HeartsContainer.setMaxHearts(player.max_health)
	HeartsContainer.updateHearts(player.health)
	player.healthChanged.connect(HeartsContainer.updateHearts)
	
	if NavigationManager.spawn_door_tag != null:
		_on_level_spawn(NavigationManager.spawn_door_tag)

func _on_level_spawn(destination_tag: String):
	var door_path = "Doors/Door_" + destination_tag
	var door = get_node(door_path) as Door
	NavigationManager.trigger_player_spawn(door.spawn.global_position, door.spawn_direction)


func _on_animation_player_animation_finished(anim_name: StringName) -> void:
	TransitionScreen.transition()
	await TransitionScreen.on_transition_finished
	get_tree().change_scene_to_file("res://levels/base_level.tscn")
