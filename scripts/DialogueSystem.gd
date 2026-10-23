extends Node2D

@onready var choice_button_scn = preload("res://for_dialogue/ChoiceButton.tscn")
@onready var target_node: Node2D = $".."

@export var player_node: CharacterBody2D

var choice_buttons: Array[Button] = []
var is_dialogue_done = false



func clear_dialogue_box():
	$VBoxContainer/Text.text = ""
	for choice in choice_buttons:
		$VBoxContainer.remove_child(choice)
	choice_buttons = []

func add_text(text: String):
	$VBoxContainer/Text.text = text


func add_choice(choice_text: String):
	var button_obj: ChoiceButton = choice_button_scn.instantiate()
	button_obj.choice_index = choice_buttons.size()
	choice_buttons.push_back(button_obj)
	button_obj.text = choice_text
	button_obj.choice_selected.connect(_on_choice_selected)
	$VBoxContainer.add_child(button_obj)

func _on_choice_selected(choice_index: int):
	if !is_dialogue_done:
		($"../EzDialogue" as EzDialogue).next(choice_index)
	else:
		clear_dialogue_box()
		$Panel.visible = false
		player_node.can_move = true
