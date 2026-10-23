extends Node2D

@export var dialogue_json: JSON
@export var player_node: CharacterBody2D

@export var state = {
	"player_name": "Leticia",
	"show_only_one": true,
	"transition_one": true,
	"has_met": true
}

func _on_ez_dialogue_dialogue_generated(response: DialogueResponse) -> void:
	$DialogueBox.clear_dialogue_box()
	
	var raw_text = response.text
	var player_name = state["player_name"]
	
	if raw_text.begins_with(player_name):
		$DialogueBox/VBoxContainer/Name.visible = true
		$DialogueBox/VBoxContainer/Name.text = player_name
		
		var remaining_text = raw_text.get_slice(player_name, 1) 
		$DialogueBox/VBoxContainer/Text.text = remaining_text
	else:
		$DialogueBox/VBoxContainer/Name.visible = false
		$DialogueBox/VBoxContainer/Name.text = ""
		$DialogueBox/VBoxContainer/Text.text = raw_text

	$DialogueBox/VBoxContainer/Name.self_modulate = Color("#dc0082") 

	player_node.can_move = false
	
	if response.choices.is_empty():
		$DialogueBox.add_choice("...")
	else:
		for choice in response.choices:
			$DialogueBox.add_choice(choice)

func _on_ez_dialogue_custom_signal_received(value: Variant) -> void:
	var params = value.split(",")
	if params[0] == "set":
		#set variable command
		var variable_name = params[1]
		var variable_value = params[2]
		state [variable_name] = variable_value

func _on_ez_dialogue_end_of_dialogue_reached() -> void:
	$DialogueBox.is_dialogue_done = true
	$".".visible = false
	$"../HUD".visible = true
	$"../HeartsContainer".visible = true
	$"../Area2D".set_deferred("monitoring", false)


func _on_area_2d_body_entered(body: Node2D) -> void:
	if body.name == "Player":
		$"../HeartsContainer".hide()
		$"../HUD".hide()
		$DialogueBox.show()
		($EzDialogue as EzDialogue).start_dialogue(dialogue_json, state)
		player_node.can_move = false


func _on_area_2d_body_exited(body: Node2D) -> void:
	player_node.can_move = true
