extends CenterContainer

signal continue_pressed(secrets)

@export var placeable_secrets : BoxContainer
@onready var upgrades_data = preload("res://scripts/upgrades_data.gd")
@onready var button_container = $PanelContainer/HBoxContainer/GridContainer
@onready var continue_button = $PanelContainer/HBoxContainer/Continue

var acquired_secrets = []
var cur_secrets = []
var selected_secret
var has_reveal = false

func _ready() -> void:
	for button in button_container.get_children():
		button.connect('card_button_pressed', reveal)
		
	reset()

func reveal(selected_button):
	if has_reveal: return
	
	has_reveal = true
	continue_button.disabled = false
	
	for i in button_container.get_child_count():
		var button = button_container.get_child(i)
		var secret = cur_secrets[i]
		
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
	continue_button.disabled = true
	
	if button_container == null: return
	
	cur_secrets = getAvailableSecrets()
	
	for i in button_container.get_child_count():
		button_container.get_child(i).init(cur_secrets[i])
		

func getAcquiredSecrets(): return acquired_secrets

func getAvailableSecrets():
	var temp_secrets = upgrades_data.secrets.duplicate(true)
	var list = []
	
	# remove upgrades for support units if not yet unlocked
	for type in ['plank', 'cactus']:
		var acquires= acquired_secrets.filter(func(item): 
			return item.slug == type
		)
		
		if acquires.size() <= 0: 
			for i in temp_secrets.size() - 1:
				if temp_secrets[i].slug == 'upgrade_' + type:
					temp_secrets.remove_at(i)
				
	
	# remove limited repeatable upgrades
	for secret in upgrades_data.secrets:
		if typeof(secret.repeatable) == TYPE_INT:
			var acquires = acquired_secrets.filter(func(item): 
				return item.slug == secret.slug
			)
			
			if acquires.size() >= secret.repeatable: 
				temp_secrets.remove(secret)
	
	# remove un-repeatable upgrades
	for secret in acquired_secrets:
		if typeof(secret.repeatable) == TYPE_BOOL and not secret.repeatable:
			var index = temp_secrets.find(secret)
			
			if index != -1: temp_secrets.remove_at(index)
	
	for button in button_container.get_children():
		var index = randi() % temp_secrets.size()
		var secret = temp_secrets[index]
		
		list.append(secret)
		temp_secrets.remove_at(index)
		
	return list

func _on_continue_pressed() -> void:
	emit_signal('continue_pressed', selected_secret)

func _on_visibility_changed() -> void:
	if visible: reset()
		
