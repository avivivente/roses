extends Area2D

@export var item: InvItem

func collect():
	queue_free()
