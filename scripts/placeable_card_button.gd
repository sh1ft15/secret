extends Button

enum CARD_TYPE {plank, cactus}

@onready var sprite = $HBoxContainer/TextureRect
@onready var label = $HBoxContainer/ColorRect/Label

@export var player: Area2D
@export var card_type: CARD_TYPE

@onready var stats = [
	{
		'slug': 'plank',
		'health': 5,
		'cost': 10,
		'sprite': preload("res://sprites/plank.png"),
		'skill': null
	},
	{
		'slug': 'cactus',
		'health': 5,
		'cost': 15,
		'sprite': preload("res://sprites/cactus.png"),
		'skill': 'reflect_damage'
	}
]

signal clicked(status, card)

func _ready() -> void:
	sprite.texture = getSprite()
	label.text = str(getCost())
	
	updateAvailable(player.getNum() >= getCost())

func updateAvailable(status):
	disabled = !status
	label.modulate = Color.WHITE  if status else Color.RED

func getStats(): return stats[card_type]

func getCost(): return stats[card_type].cost

func getSprite(): return stats[card_type].sprite

func getSlug(): return stats[card_type].slug

func _on_pressed() -> void:
	if player.getNum() >= getCost():
		emit_signal('clicked', true, self)
