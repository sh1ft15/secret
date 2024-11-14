extends Node2D

enum CARD_TYPE {plank, cactus}

@onready var stats = [
	{
		'health': 5,
		'cost': 10,
		'sprite': preload("res://sprites/plank.png"),
		'reflect_damage': false # reflect damage
	},
	{
		'health': 5,
		'cost': 15,
		'sprite': preload("res://sprites/cactus.png"),
		'reflect_damage': true # reflect damage
	}
]

@onready var sprite = $Sprite2D
@onready var label = $Label
@export var card_type: CARD_TYPE

signal clicked(status, card)

var player 

func _ready() -> void:
	player = get_tree().get_first_node_in_group('player')	
	updateAvailable(player.getNum() >= getCost())
	sprite.texture = getSprite()
	label.text = str(getCost())

func getStats(): return stats[card_type]

func getCost(): return stats[card_type].cost

func getSprite(): return stats[card_type].sprite
	
func updateAvailable(status):
	if status: label.modulate = Color.WHITE
	else: label.modulate = Color.RED
	
func _on_input_event(viewport: Node, event: InputEvent, shape_idx: int) -> void:
	if player.getNum() < getCost(): return
	
	if event.is_action_pressed("left_mouse_click"): 
		emit_signal('clicked', true, self)

func _on_area_entered(area: Area2D) -> void:
	sprite.scale = Vector2(.3, .3)


func _on_area_exited(area: Area2D) -> void:
	sprite.scale = Vector2(.2, .2)
