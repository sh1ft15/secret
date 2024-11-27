extends Control

var button_entered = preload("res://audios/button_entered.wav")

@onready var audio = $AudioStreamPlayer2D

func _on_button_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/menu.tscn")

func _on_button_mouse_entered() -> void:
	playAudio(button_entered)

func playAudio(stream):
	audio.stream = stream
	audio.play()
