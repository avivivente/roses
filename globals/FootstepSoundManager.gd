extends Node

@export var tilemaps: Array[TileMapLayer] = []

const FOOTSTEP_SOUNDS = {
	"dirt": [
		preload("res://audio/footstep/dirt1.wav"),
		preload("res://audio/footstep/dirt2.wav"),
		preload("res://audio/footstep/dirt3.wav"),
	],
	"grass": [
		preload("res://audio/footstep/grass1.wav"),
		preload("res://audio/footstep/grass2.wav"),
		preload("res://audio/footstep/grass3.wav"),
	],
	"stone": [
		preload("res://audio/footstep/stone1.wav"),
		preload("res://audio/footstep/stone2.wav"),
		preload("res://audio/footstep/stone3.wav"),
	]
}

const MAX_PLAYERS = 8
var _audio_pool: Array[AudioStreamPlayer2D] = []
var _pool_index: int = 0

func _ready() -> void:
	for i in range(MAX_PLAYERS):
		var player = AudioStreamPlayer2D.new()
		add_child(player)
		_audio_pool.append(player)

func play_footstep(global_position: Vector2) -> void:
	var current_tile_data: TileData = null
	
	for i in range(tilemaps.size() - 1, -1, -1):
		var tilemap = tilemaps[i]
		if not tilemap: continue
		
		var local_pos = tilemap.to_local(global_position)
		var tile_position = tilemap.local_to_map(local_pos)
		var data = tilemap.get_cell_tile_data(tile_position)
		
		if data:
			current_tile_data = data
			break 

	if not current_tile_data:
		return

	var tile_type = current_tile_data.get_custom_data("footstep_sound")
	if not FOOTSTEP_SOUNDS.has(tile_type):
		return


	var audio_player = _audio_pool[_pool_index]
	_pool_index = (_pool_index + 1) % MAX_PLAYERS
	

	audio_player.global_position = global_position
	audio_player.stream = FOOTSTEP_SOUNDS[tile_type].pick_random()
	audio_player.play()
