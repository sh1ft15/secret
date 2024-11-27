extends Control

# var main_scene = preload("res://scenes/main.tscn").instantiate()

func _on_button_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/menu.tscn")
