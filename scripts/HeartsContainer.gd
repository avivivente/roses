extends HBoxContainer

@onready var HeartGuiClass = preload("res://scene/heart_gui.tscn")

var max_health: int 
var health: int 

func setMaxHearts(max: int):
	for i in range(max):
		var heart = HeartGuiClass.instantiate()
		add_child(heart)

func updateHearts(health: int):
	var hearts = get_children()
	
	for i in range(health):
		hearts[i].update(true)
	
	for i in range(health, hearts.size()):
		hearts[i].update(false)
