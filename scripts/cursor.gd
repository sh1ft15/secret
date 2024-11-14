extends Node2D

@onready var _sprite = $Sprite2D
@onready var field = $"../Field"
@onready var player = $"../Player"

var is_placing_item = false
var placing_item = null

func _ready() -> void:
	var cards = get_tree().get_nodes_in_group('card')
	for card in cards: card.connect('clicked', setPlacingItem)
	
	visible = false
	_sprite.modulate = Color(1, 1, 1, .3)

func _process(delta: float) -> void:
	if enable: position = get_global_mouse_position()
			
func enable(sprite):
	_sprite.texture = sprite
	visible = true

func disable():
	_sprite.texture = null
	visible = false

func setPlacingItem(status, card):
	is_placing_item = status
	placing_item = card
	
	if status: enable(card.getSprite())
	else: disable()

func getPlacingItem(): return placing_item

func isPlacingItem(): return is_placing_item

func _on_area_entered(area: Area2D) -> void:
	if area.name == 'Field':
		_sprite.modulate = Color(1, 1, 1, .3)

func _on_area_exited(area: Area2D) -> void:
	if area.name == 'Field':
		_sprite.modulate = Color(1, 0, 0, .3)

func _on_field_input_event(viewport: Node, event: InputEvent, shape_idx: int) -> void:
	if is_placing_item && event.is_action_pressed("left_mouse_click"):
		var card = getPlacingItem()
		
		get_parent().spawnSupportUnit(get_global_mouse_position(), card)
		player.setNum(-card.getCost())
		setPlacingItem(false, null)
