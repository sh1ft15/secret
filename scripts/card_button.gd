extends Button

@onready var sprite = $HBoxContainer/TextureRect
@onready var desc = $HBoxContainer/ColorRect/Label

signal card_button_pressed(button)

func update(p_sprite, p_desc, p_color = null):
	sprite.texture = p_sprite	
	desc.get_parent().visible = p_desc != ''
	desc.text = p_desc
	desc.modulate = p_color if p_color != null else Color.WHITE

func _on_pressed() -> void:
	emit_signal('card_button_pressed', self)
