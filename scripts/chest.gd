extends StaticBody2D

@onready var animation_player: AnimationPlayer = $AnimationPlayer
@onready var interaction_area: InteractionArea = $InteractionArea
@onready var leticia: CharacterBody2D = $"../../Leticia"
@onready var canvas_layer: CanvasLayer = $"../../CanvasLayer"

var is_open: bool = false
var player_in_area: bool = false

func _ready():
	interaction_area.interact = Callable(self, "_open_chest")

func _process(delta):
	if player_in_area:
		if Input.is_action_just_pressed("interact"):
			random_dialogue()


func _open_chest():
	if is_open: return
	
	is_open = true
	animation_player.play("open")

func _on_interaction_area_body_entered(body: Node2D) -> void:
	if body.is_in_group("Player"):
		player_in_area = true

func _on_interaction_area_body_exited(body: Node2D) -> void:
	if body.is_in_group("Player"):
		player_in_area = false
	if is_open and body.name == "Player":
		is_open = false
		animation_player.play_backwards("open")

func random_dialogue():
	Dialogic.timeline_ended.connect(dialogue_ended)
	leticia.can_move = false
	
	var dialogue_line = randi_range(1,8)
	Dialogic.start("chest_dialogue_" + str(dialogue_line))
	interaction_area.set_deferred("monitoring", false)
	canvas_layer.hide()
	animation_player.play("open")

func dialogue_ended():
	Dialogic.timeline_ended.disconnect(dialogue_ended)
	leticia.can_move = true
	interaction_area.set_deferred("monitoring", true)
	canvas_layer.show()
	animation_player.play_backwards("open")
