extends Node

func _ready() -> void:
	apply_display_settings()
	apply_volume_settings()
	

func apply_display_settings() -> void:
	var display_settings: Dictionary = ConfigFileHandler.load_displaymode_setting()
	var active_index: int = 0 
	
	if display_settings.has("windowed_maximized"):
		active_index = display_settings["windowed_maximized"]
	elif display_settings.has("windowed"):
		active_index = display_settings["windowed"]
	elif display_settings.has("fullscreen"):
		active_index = display_settings["fullscreen"]
		
	match active_index:
		0: DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_MAXIMIZED)
		1: DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED)
		2: DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_EXCLUSIVE_FULLSCREEN)

func apply_volume_settings() -> void:
	var volume_settings = ConfigFileHandler.load_volume_setting()
	
	# Extract values, defaulting to 1.0 (100% volume) if missing
	var master_v = min(volume_settings.get("master", 1.0), 1.0)
	var music_v = min(volume_settings.get("music", 1.0), 1.0)
	var ambience_v = min(volume_settings.get("ambience", 1.0), 1.0)
	var sfx_v = min(volume_settings.get("sfx", 1.0), 1.0)
	var ui_v = min(volume_settings.get("ui", 1.0), 1.0)
	
	# Apply directly to Godot's AudioServer buses
	set_bus_volume("Master", master_v)
	set_bus_volume("Music", music_v)
	set_bus_volume("Ambience", ambience_v)
	set_bus_volume("SFX", sfx_v)
	set_bus_volume("UI", ui_v)

func set_bus_volume(bus_name: String, value: float) -> void:
	var bus_index = AudioServer.get_bus_index(bus_name)
	if bus_index != -1:
		# Convert linear 0.0-1.0 slider values to Decibels (dB)
		AudioServer.set_bus_volume_db(bus_index, linear_to_db(value))
