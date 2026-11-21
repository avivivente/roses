extends Control

@onready var task: Label = $MarginContainer/MarginContainer/VBoxContainer/Task
@onready var task_1: Label = $MarginContainer/MarginContainer/VBoxContainer/Task1
@onready var item: Label = $MarginContainer/MarginContainer/VBoxContainer/Item

func _ready() -> void:
	task.hide()
	task_1.hide()
	item.hide()

func _process(_delta: float) -> void:
	update_task_ui()
	update_item_ui()

func update_task_ui() -> void:
	if Dialogic.VAR.tasks.has_rose:
		task.show()
		task.text = "- Give Rose to Old Lady"
	elif Dialogic.VAR.tasks.task1:
		task.show()
		task.text = "- Look for Old Lady's missing item"
	elif State.task0_active:
		task.show()
		task.text = "- Talk to Old Lady"
	else:
		task.hide()

	if Dialogic.VAR.NPCs.has_talked_to_boy:
		task_1.show()
		task_1.text = "- Talk to the boy."
	else:
		task_1.hide()

func update_item_ui() -> void:
	if not Dialogic.VAR.areas.has_key1:
		item.hide()
		return

	item.show()
	if Dialogic.VAR.areas.has_interacted_with_gate and not Dialogic.VAR.areas.has_interacted_area2_gate:
		item.text = "- Use Key on Fence Gate"
	else:
		item.text = "- Figure out where to use Key"
