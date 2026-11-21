extends Node

# Global variables teehee
var start_game = false
var has_triggered_intro = false
var task0_active = false
var has_entered_cave = false
var task1_done = false
var has_key1 = false
var has_area2_key = false
var has_opened_gate = false
var area2_gate_opened = false
var picture_frame = false
var has_talked_to_boy = false
var end_credits = false
var has_rose = false

func reset():
	start_game = false
	has_triggered_intro = false
	task0_active = false
	has_entered_cave = false
	task1_done = false
	has_key1 = false
	has_area2_key = false
	has_opened_gate = false
	area2_gate_opened = false
	picture_frame = false
	has_talked_to_boy = false
	end_credits = false
	has_rose = false
	
	NavigationManager.current_level_tag = "base_level"
	NavigationManager.spawn_door_tag = null
