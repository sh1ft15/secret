extends Control

var button_entered = preload("res://audios/button_entered.wav")

@onready var audio = $AudioStreamPlayer2D
@onready var header = $Panel/Header

func _on_start_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/main.tscn")

func _on_credit_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/credit.tscn")

func _on_tutorial_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/tutorial_screen.tscn")

func _on_credit_mouse_entered() -> void:
	playAudio(button_entered)

func _on_start_mouse_entered() -> void:
	playAudio(button_entered)
	
func playAudio(stream):
	audio.stream = stream
	audio.play()

func _on_header_mouse_entered() -> void:
	header.get_child(0).label_settings.set_font_size(55)
	header.get_child(1).label_settings.set_font_size(25)
	playAudio(button_entered)

func _on_header_mouse_exited() -> void:
	header.get_child(0).label_settings.set_font_size(50)
	header.get_child(1).label_settings.set_font_size(20)
