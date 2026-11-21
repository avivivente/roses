extends Node2D

@onready var map_loop: AnimationPlayer = $AnimationPlayer
@onready var credits: AnimationPlayer = $AnimationPlayer2
@onready var house_loop: AnimationPlayer = $AnimationPlayer3
@onready var post_credit: AnimationPlayer = $Post_Credit
@onready var fade: AnimationPlayer = $CanvasLayer/FadeOverlay/AnimationPlayer
@onready var fade_overlay: ColorRect = $CanvasLayer/FadeOverlay
@onready var return_menu_box: VBoxContainer = $CanvasLayer/VBoxContainer2
@onready var end_credits_music: AudioStreamPlayer = $EndCreditsMusic


func _ready() -> void:
	end_credits_music.play()
	return_menu_box.hide()
	fade.play("fade_to_normal")
	map_loop.play("map_loop")
	credits.play("credits")

func _on_timer_timeout() -> void:
	fade_overlay.show()
	fade.play("fade_to_black")
	map_loop.stop()
	house_loop.play("house_loop")
	fade.play("fade_to_normal")

func _on_post_credit_timeout() -> void:
	fade_overlay.show()
	fade.play("fade_to_black")
	house_loop.stop()
	post_credit.play("post_credit")
	fade.play("fade_to_normal")
	await post_credit.animation_finished
	show_return()

func show_return():
	return_menu_box.show()

func _on_yes_pressed() -> void:
	get_tree().change_scene_to_file("res://menu.tscn")

func _on_no_pressed() -> void:
	get_tree().reload_current_scene()

func _on_skip_pressed() -> void:
	fade_overlay.show()
	fade.play("fade_to_black")
	map_loop.stop()
	house_loop.stop()
	credits.stop()
	end_credits_music.play(90)
	post_credit.play("post_credit")
	fade.play("fade_to_normal")
	await post_credit.animation_finished
	show_return()
