extends Panel

@onready var sprite_2d: Sprite2D = $Sprite2D

func update(whole: bool):
	if whole:
		sprite_2d.frame = 0
	else:
		sprite_2d.frame = 4
