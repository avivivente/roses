extends Node

const scene_baselevel = preload("res://levels/base_level.tscn")
const scene_level1 = preload("res://levels/level_1.tscn")
const scene_level2 = preload("res://levels/level_2.tscn")
const scene_area2 = preload("res://levels/area_2.tscn")

signal on_trigger_player_spawn

var spawn_door_tag
var current_level_tag: String = "base_level" # Tracks where the player currently is

func go_to_level(level_tag: String, destination_tag: String = ""):
	var scene_to_load = get_scene_from_tag(level_tag)
			
	if scene_to_load != null:
		current_level_tag = level_tag
		TransitionScreen.transition()
		await TransitionScreen.on_transition_finished
		spawn_door_tag = destination_tag
		get_tree().change_scene_to_packed(scene_to_load)

func get_scene_from_tag(level_tag: String) -> PackedScene:
	match level_tag:
		"base_level":
			return scene_baselevel
		"level_1":
			return scene_level1
		"level_2":
			return scene_level2
		"area_2":
			return scene_area2
	return null


func continue_last_level() -> void:
	var scene_to_load = get_scene_from_tag(current_level_tag)
	if scene_to_load != null:
		get_tree().change_scene_to_packed(scene_to_load)

func trigger_player_spawn(position: Vector2, direction: String):
	on_trigger_player_spawn.emit(position, direction)
