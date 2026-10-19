class_name FollowMovementC
extends Node

@export var patrol_speed: float = 100
@export var chase_speed: float = 150
@export var return_speed: float = 300.0
@export var arrival_distance: float = 4

@export var patrol_point_1: Marker2D
@export var patrol_point_2: Marker2D
@export var patrol_point_3: Marker2D
@export var patrol_point_4: Marker2D
@export var patrol_point_5: Marker2D
@export var patrol_point_6: Marker2D

@onready var parent: CharacterBody2D = get_parent()

var target: CharacterBody2D = null
var patrol_positions: Array[Vector2] = []
var patrol_index: int = 0
var patrol_direction: int = 1
var returning: bool = false


func _ready() -> void:
	if patrol_point_1:
		patrol_positions.append(patrol_point_1.global_position)

	if patrol_point_2:
		patrol_positions.append(patrol_point_2.global_position)

	if patrol_point_3:
		patrol_positions.append(patrol_point_3.global_position)

	if patrol_point_4:
		patrol_positions.append(patrol_point_4.global_position)

	if patrol_point_5:
		patrol_positions.append(patrol_point_5.global_position)

	if patrol_point_6:
		patrol_positions.append(patrol_point_6.global_position)

	if not patrol_positions.is_empty():
		patrol_index = get_nearest_patrol_index()


func _physics_process(_delta: float) -> void:
	# Stop chasing if the player hides in a locker.
	if is_instance_valid(target) and target.is_in_group("hidden"):
		target = null
		start_returning()

	# Chase the player.
	if is_instance_valid(target):
		returning = false
		move_toward_position(target.global_position, chase_speed)

	# Return to the nearest patrol point.
	elif returning:
		if patrol_positions.is_empty():
			parent.velocity = Vector2.ZERO
			returning = false
		else:
			var destination: Vector2 = patrol_positions[patrol_index]
			move_toward_position(destination, return_speed)

			if parent.global_position.distance_to(destination) <= arrival_distance:
				parent.velocity = Vector2.ZERO
				returning = false

				# Continue in the current patrol direction.
				if patrol_positions.size() > 1:
					if patrol_index >= patrol_positions.size() - 1:
						patrol_direction = -1
					elif patrol_index <= 0:
						patrol_direction = 1

					patrol_index += patrol_direction

	# Resume normal patrol.
	else:
		patrol()

	parent.move_and_slide()


func move_toward_position(
	destination: Vector2,
	movement_speed: float
) -> void:
	var direction: Vector2 = destination - parent.global_position

	if direction.length() <= arrival_distance:
		parent.velocity = Vector2.ZERO
	else:
		parent.velocity = direction.normalized() * movement_speed


func patrol() -> void:
	if patrol_positions.is_empty():
		parent.velocity = Vector2.ZERO
		return

	var destination: Vector2 = patrol_positions[patrol_index]
	move_toward_position(destination, patrol_speed)

	if parent.global_position.distance_to(destination) <= arrival_distance:
		# Reverse at either endpoint.
		if patrol_index >= patrol_positions.size() - 1:
			patrol_direction = -1
		elif patrol_index <= 0:
			patrol_direction = 1

		patrol_index += patrol_direction


func start_returning() -> void:
	if patrol_positions.is_empty():
		return

	# Find the closest patrol point.
	patrol_index = get_nearest_patrol_index()
	returning = true


func get_nearest_patrol_index() -> int:
	var nearest_index: int = 0
	var nearest_distance: float = INF

	for i in range(patrol_positions.size()):
		var distance: float = parent.global_position.distance_to(
			patrol_positions[i]
		)

		if distance < nearest_distance:
			nearest_distance = distance
			nearest_index = i

	return nearest_index


func _on_follow_area_body_entered(body: Node2D) -> void:
	if body is CharacterBody2D and not body.is_in_group("hidden"):
		target = body
		returning = false


func _on_follow_area_body_exited(body: Node2D) -> void:
	if body == target:
		target = null
		start_returning()


func disable() -> void:
	set_physics_process(false)
	parent.velocity = Vector2.ZERO
