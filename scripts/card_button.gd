extends Button

@onready var sprite = $HBox/TextureRect
@onready var desc_rect = $HBox/Desc
@onready var desc_label = $HBox/Desc/Label
@onready var cost_rect = $HBox/Cost
@onready var cost_label = $HBox/Cost/HBox/Label
@onready var default_icon = load("res://sprites/secret_test.png")

var cur_cost = 0

signal card_button_pressed(button)

func init(upgrade):
	modulate = Color.WHITE
	disabled = false
	
	sprite.texture = default_icon
	desc_rect.visible = false
	cost_rect.visible = true
	
	cur_cost = randi_range(upgrade.cost_min, upgrade.cost_max)
	cost_label.text = str(cur_cost)

func update(p_sprite, p_desc):
	sprite.texture = p_sprite	
	cost_rect.visible = false
	desc_rect.visible = true
	desc_label.text = p_desc

func _on_pressed() -> void:
	emit_signal('card_button_pressed', self)
