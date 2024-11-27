extends Control

var button_entered = preload("res://audios/button_entered.wav")

@onready var sfx_slider = $Panel/VBoxContainer/List/SFX/SFXSlider
@onready var bgm_slider = $Panel/VBoxContainer/List/BGM/BGMSlider
@onready var audio = $AudioStreamPlayer2D

signal back_pressed
signal sfx_updated
signal bgm_updated

func init(values):
	sfx_slider.value = values.sfx
	bgm_slider.value = values.bgm


	
func _on_button_pressed() -> void:
	emit_signal('back_pressed')

func playAudio(stream):
	audio.stream = stream
	audio.play()

func _on_sfx_slider_drag_ended(value_changed: bool) -> void:
	emit_signal('sfx_updated', sfx_slider.value)

func _on_bgm_slider_drag_ended(value_changed: bool) -> void:
	emit_signal('bgm_updated', bgm_slider.value)

func _on_main_menu_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/menu.tscn")

func _on_back_mouse_entered() -> void:
	playAudio(button_entered)

func _on_main_menu_mouse_entered() -> void:
	playAudio(button_entered)
