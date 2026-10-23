extends Node2D

@onready var animated_sprite_2d: AnimatedSprite2D = $Player/AnimatedSprite2D
@onready var hearts_container: HBoxContainer = $CanvasLayer/HeartsContainer
@onready var player: CharacterBody2D = $Player

var level: int = 1
var current_level_root: Node = null
var max_health: int 
var health: int 

func _ready():
	
	get_tree().get_nodes_in_group("Player")
	
	if player == null:
		push_error("Error: Player node not found! Check your node path.")
		return
		
	if hearts_container == null:
		push_error("Error: HeartsContainer node not found! Check your node path.")
		return
	
	hearts_container.setMaxHearts(player.max_health)
	hearts_container.updateHearts(player.health)
	player.healthChanged.connect(hearts_container.updateHearts)
	
	if NavigationManager.spawn_door_tag != null:
		_on_level_spawn(NavigationManager.spawn_door_tag)
	


func _on_level_spawn(destination_tag: String):
	var door_path = "Doors/Door_" + destination_tag
	var door = get_node(door_path) as Door
	NavigationManager.trigger_player_spawn(door.spawn.global_position, door.spawn_direction)


func _on_player_died() -> void:
	TransitionScreen.transition()
	await TransitionScreen.on_transition_finished
	PlayerStats.reset_health()
	get_tree().reload_current_scene()
