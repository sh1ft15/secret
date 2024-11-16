extends CenterContainer

const secrets = [
	{
		'slug': 'increase_health', 
		'desc': 'Health +1', 
		'repeatable': true,
		'sprite': preload('res://sprites/secret_test.png')
	},
	{
		'slug': 'increase_max_point', 
		'desc': 'Max Points +1', 
		'repeatable': true,
		'sprite': preload('res://sprites/secret_test.png')
	},
	{
		'slug': 'increase_shoot_rate', 
		'desc': 'Shoot Rate +1', 
		'repeatable': true,
		'sprite': preload('res://sprites/secret_test.png')
	},
	{
		'slug': 'increase_shoot_count', 
		'desc': 'Shoot Amount +1', 
		'repeatable': true,
		'sprite': preload('res://sprites/leave.png')
	},
	{
		'slug': 'plank', 
		'desc': 'Can place a plank. It does nothing',
		'repeatable': false,
		'sprite': preload("res://sprites/plank.png")
	},
	{
		'slug': 'cactus', 
		'desc': 'Can place a cactus. It hurt the bugs',
		'repeatable': false,
		'sprite': preload("res://sprites/cactus.png")
	}
]

signal continue_pressed(secrets)

@onready var button_container = $PanelContainer/HBoxContainer/GridContainer
@onready var default_icon = load("res://sprites/secret_test.png")

var acquired_secrets = []
var selected_secret
var has_reveal = false

func _ready() -> void:
	for button in button_container.get_children():
		button.connect('card_button_pressed', reveal)
		
	reset()

func reveal(selected_button):
	if has_reveal: return
	
	has_reveal = true
	
	var temp_secrets = secrets.duplicate(true)
	
	# remove un-repeatable buffs
	for secret in acquired_secrets:
		if not secret.repeatable:
			var index = temp_secrets.find(secret)
			
			if index != -1: temp_secrets.remove_at(index)
	
	for button in button_container.get_children():
		var index = randi() % temp_secrets.size()
		var secret = temp_secrets[index]
		
		temp_secrets.remove_at(index)
		button.disabled = true
		
		if button == selected_button: 
			button.update(secret.sprite, secret.desc)
			selected_secret = secret
			acquired_secrets.append(secret)
		else:
			button.modulate = Color.GRAY

func reset():
	has_reveal = false
	selected_secret = null
	
	if button_container == null: return
	
	for button in button_container.get_children():
		button.update(default_icon, '')
		button.modulate = Color.WHITE
		button.disabled = false

func _on_continue_pressed() -> void:
	emit_signal('continue_pressed', selected_secret)

func _on_visibility_changed() -> void:
	if visible: reset()
		
