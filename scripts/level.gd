extends Node2D

@onready var hearts_container: HBoxContainer = $CanvasLayer/HeartsContainer
@onready var player: CharacterBody2D = $Leticia
@onready var animation_player: AnimationPlayer = $CanvasLayer2/FadeOverlay/AnimationPlayer
@onready var quit: TextureButton = $Menuscreen/Control/VBoxContainer/Quit

var level: int = 1
var current_level_root: Node = null
var max_health: int 
var health: int 

func _ready():
	animation_player.play("fade_to_normal")
	
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
	
	if not has_node(door_path):
		await get_tree().process_frame
		
	if has_node(door_path):
		var door = get_node(door_path) as Door
		if door and door.spawn:
			NavigationManager.trigger_player_spawn(door.spawn.global_position, door.spawn_direction)
		else:
			print_debug("Error: Door found, but its 'spawn' marker child node is missing!")
	else:
		print_debug("Error: Total failure finding door path: " + door_path + " after restarting.")


func _on_player_died() -> void:
	TransitionScreen.transition()
	await TransitionScreen.on_transition_finished
	PlayerStats.reset_health()
	get_tree().reload_current_scene()
