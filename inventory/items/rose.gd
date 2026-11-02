extends StaticBody2D

@export var item: InvItem

@onready var rose: StaticBody2D = $"."
@onready var interaction_area: InteractionArea = $InteractionArea
@onready var pickup_area: Area2D = $pickup_area

var player = null
var player_in_area = false

func _ready():
	if State.task1_done:
		rose.visible = false
		interaction_area.set_deferred("monitoring", false)
		pickup_area.set_deferred("monitoring", false)

func _process(delta: float) -> void:
	if player_in_area:
		if Input.is_action_just_pressed("interact"):
			collect_rose()
			Dialogic.VAR.tasks.has_rose1 = true
			queue_free()

func _on_pickup_area_body_entered(body):
	if body.is_in_group("Player"):
		player_in_area = true
		player = body

func _on_pickup_area_body_exited(body: Node2D) -> void:
	if body.is_in_group("Player"):
		player_in_area = false

func collect_rose():
	player.collect(item)
