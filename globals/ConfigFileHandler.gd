extends Node

var config = ConfigFile.new()
const SETTINGS_FILE_PATH = "user://settings.ini"


func _ready():
	if !FileAccess.file_exists(SETTINGS_FILE_PATH):
		config.set_value("display_mode", "windowed_maximixed", 0)
		config.set_value("display_mode", "windowed", 1)
		config.set_value("display_mode", "fullscreen", 2)
		
		config.set_value("volume", "master", 1.0)
		config.set_value("volume", "music", 1.0)
		config.set_value("volume", "ambience", 1.0)
		config.set_value("volume", "ui", 1.0)
		config.set_value("volume", "sfx", 1.0)
		
		config.save(SETTINGS_FILE_PATH)
	else:
		config.load(SETTINGS_FILE_PATH)


func save_displaymode_setting(section: String, index: int) -> void:
	if config.has_section("display_mode"):
		config.erase_section("display_mode")
	
	var key_name: String = ""
	match index:
		0: key_name = "windowed_maximized"
		1: key_name = "windowed"
		2: key_name = "fullscreen"
		_: key_name = "windowed_maximized" 
		
	config.set_value("display_mode", key_name, index)
	config.save(SETTINGS_FILE_PATH) 



func load_displaymode_setting():
	var displaymode_setting = {}
	for key in config.get_section_keys("display_mode"):
		displaymode_setting[key] = config.get_value("display_mode", key)
	return displaymode_setting

func save_volume_setting(key: String, value):
	config.set_value("volume", key, value)
	config.save(SETTINGS_FILE_PATH)


func load_volume_setting():
	var volume_setting = {}
	for key in config.get_section_keys("volume"):
		volume_setting[key] = config.get_value("volume", key)
	return volume_setting
