extends CanvasLayer

signal options_closed

@onready var canvas_layer: CanvasLayer = $"."
@onready var press: AudioStreamPlayer = $ButtonPress
@onready var hover: AudioStreamPlayer = $ButtonHover
@onready var master_volume: HSlider = $Control/VBoxContainer2/MasterVolume
@onready var music_volume: HSlider = $Control/VBoxContainer2/MusicVolume
@onready var ambience_volume: HSlider = $Control/VBoxContainer2/AmbienceVolume
@onready var sfx_volume: HSlider = $Control/VBoxContainer2/SFXVolume
@onready var ui_volume: HSlider = $Control/VBoxContainer2/UIVolume
@onready var display_mode: OptionButton = $Control/NinePatchRect/DisplayMode

func _ready():
	hide()
	var display_settings: Dictionary = ConfigFileHandler.load_displaymode_setting()
	
	var active_index: int = 0 
	
	if display_settings.has("windowed_maximized"):
		active_index = display_settings["windowed_maximized"]
	elif display_settings.has("windowed"):
		active_index = display_settings["windowed"]
	elif display_settings.has("fullscreen"):
		active_index = display_settings["fullscreen"]
		
	display_mode.select(active_index)
	
	match active_index:
		0: DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_MAXIMIZED)
		1: DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED)
		2: DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_EXCLUSIVE_FULLSCREEN)
	
	
	var volume_settings = ConfigFileHandler.load_volume_setting()
	
	master_volume.value = min(volume_settings.get("master", 1.0), 1.0) * 10
	music_volume.value = min(volume_settings.get("music", 1.0), 1.0) * 10
	ambience_volume.value = min(volume_settings.get("ambience", 1.0), 1.0) * 10
	sfx_volume.value = min(volume_settings.get("sfx", 1.0), 1.0) * 10
	ui_volume.value = min(volume_settings.get("ui", 1.0), 1.0) * 10




func _on_back_pressed() -> void:
	visible = false
	press.play()
	options_closed.emit()
func _on_back_mouse_entered() -> void:
	hover.play()


func _on_option_button_pressed() -> void:
	press.play()


func _on_display_mode_item_selected(index: int) -> void:
	if index == 0:
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_MAXIMIZED)
	elif index == 1:
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED)
	elif index == 2:
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_FULLSCREEN)
		
	ConfigFileHandler.save_displaymode_setting("display_mode", index)

func _on_master_volume_drag_ended(value_changed: bool) -> void:
	if value_changed:
		ConfigFileHandler.save_volume_setting("master", master_volume.value / 10)


func _on_music_volume_drag_ended(value_changed: bool) -> void:
	if value_changed:
		ConfigFileHandler.save_volume_setting("music", music_volume.value / 10)


func _on_ambience_volume_drag_ended(value_changed: bool) -> void:
	if value_changed:
		ConfigFileHandler.save_volume_setting("ambience", ambience_volume.value / 10)


func _on_sfx_volume_drag_ended(value_changed: bool) -> void:
	if value_changed:
		ConfigFileHandler.save_volume_setting("sfx", sfx_volume.value / 10)


func _on_ui_volume_drag_ended(value_changed: bool) -> void:
	if value_changed:
		ConfigFileHandler.save_volume_setting("ui", ui_volume.value / 10)
