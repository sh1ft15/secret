extends CenterContainer

const secrets = [
	# buffs
	{
		'slug': 'health', 'desc': 'Increase player health by 1', 
		'sprite': null, 'cons': false
	},
	{
		'slug': 'increase_max_point', 'desc': 'Increase maximum points', 
		'sprite': null, 'cons': false
	},
	{
		'slug': 'plank', 'desc': 'Can place a plank. It does nothing',
		'sprite': preload("res://sprites/plank.png"), 'cons': false
	},
	{
		'slug': 'cactus', 'desc': 'Can place a cactus. It hurt the bugs',
		'sprite': preload("res://sprites/cactus.png"), 'cons': false
	},
	# debuffs
	{
		'slug': 'enemy_armor', 'desc': 'Bug have more armor', 
		'sprite': null, 'cons': true
	},
	{
		'slug': 'reset_point', 'desc': 'Reset points', 
		'sprite': null, 'cons': true
	},
	{
		'slug': 'enemy_cover', 'desc': 'Bug can use cover', 
		'sprite': preload("res://sprites/box.png"), 'cons': true
	}
]

signal continue_pressed

@onready var button_1 = $PanelContainer/HBoxContainer/GridContainer/Button_1
@onready var button_2 = $PanelContainer/HBoxContainer/GridContainer/Button_2
@onready var button_3 = $PanelContainer/HBoxContainer/GridContainer/Button_3
@onready var secret_icon = load("res://sprites/secret.png")

var selected_secret
var has_reveal = false

func _ready() -> void:
	reset()

func reveal(selected_button):
	if has_reveal: return
	
	has_reveal = true
	
	var temp_secrets = secrets.duplicate(true)
	
	for button in [button_1, button_2, button_3]:
		var index = randi() % temp_secrets.size()
		var secret = temp_secrets[index]
		var color = Color.RED if secret.cons else Color.GREEN
		
		temp_secrets.remove_at(index)
		
		if secret.sprite != null:
			button.icon = secret.sprite
		
		if button == selected_button: 
			button.get_child(0).modulate = color
			selected_secret = secret
		else: 
			color = color * 0.7
			button.get_child(0).modulate = color
			button.disabled = true
		
		button.get_node('Title').text = secret.desc

func reset():
	has_reveal = false
	
	if button_1 != null and button_2 != null and button_3 != null:
		for button in [button_1, button_2, button_3]:
			button.get_child(0).text = ''
			button.get_child(0).modulate = Color.WHITE
			button.icon = secret_icon
			button.disabled = false
			# button.modulate = Color.WHITE


func _on_continue_pressed() -> void:
	emit_signal('continue_pressed')

func _on_button_1_pressed() -> void:
	reveal(button_1)

func _on_button_2_pressed() -> void:
	reveal(button_2)

func _on_button_3_pressed() -> void:
	reveal(button_3)

func _on_visibility_changed() -> void:
	if not visible: reset()
		
