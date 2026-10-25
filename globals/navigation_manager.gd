extends Node

const scene_baselevel = preload("res://levels/base_level.tscn")
const scene_level1 = preload("res://levels/level_1.tscn")
const scene_level2 = preload("res://levels/level_2.tscn")

signal on_trigger_player_spawn

var spawn_door_tag

func go_to_level(level_tag, destination_tag):
	var scene_to_load
	
	match level_tag:
		"base_level":
			scene_to_load = scene_baselevel
		"level_1":
			scene_to_load = scene_level1
		"level_2":
			scene_to_load = scene_level2
	if scene_to_load != null:
		TransitionScreen.transition()
		await TransitionScreen.on_transition_finished
		spawn_door_tag = destination_tag
		get_tree().change_scene_to_packed(scene_to_load)

func trigger_player_spawn(position: Vector2, direction: String):
	on_trigger_player_spawn.emit(position, direction)
