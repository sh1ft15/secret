extends Button

@onready var sprite = $HBox/TextureRect
@onready var desc_rect = $HBox/Desc
@onready var desc_label = $HBox/Desc/Label
@onready var cost_rect = $HBox/Cost
@onready var cost_label = $HBox/Cost/HBox/Label
@onready var default_icon = load("res://sprites/secret_test.png")

var cur_secret = null
var cur_cost = 0

signal card_button_pressed(button)

func init(secret):
	modulate = Color.WHITE
	disabled = false
	
	sprite.texture = default_icon
	desc_rect.visible = false
	cost_rect.visible = true
	
	cur_secret = secret
	cur_cost = randi_range(5, 20)
	cost_label.text = str(cur_cost)

func open():
	sprite.texture = cur_secret.sprite	
	desc_label.text = cur_secret.desc
	cost_rect.visible = false
	desc_rect.visible = true

func setAffordable(status):
	cost_label.modulate = Color.WHITE if status else Color.RED

func getCost(): return cur_cost

func getSecret(): return cur_secret

func _on_pressed() -> void:
	emit_signal('card_button_pressed', self)
