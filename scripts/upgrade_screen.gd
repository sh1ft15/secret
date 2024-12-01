extends CenterContainer

signal continue_pressed(secrets)

var upgrades_data = preload("res://scripts/upgrades_data.gd")

@onready var title_label = $PanelContainer/HBoxContainer/HBox/Title
@onready var button_container = $PanelContainer/HBoxContainer/GridContainer
@onready var continue_button = $PanelContainer/HBoxContainer/Continue
@onready var player_coin = $PanelContainer/HBoxContainer/HBox/Coin

@export var player : Area2D

var acquired_secrets = []
var cur_secrets = []
var selected_secrets = []

func _ready() -> void:
	for button in button_container.get_children():
		button.connect('card_button_pressed', reveal)
		
	reset()

func init(score):
	title_label.text = 'Wave ' + str(score.wave) + ' Completed'

func reveal(card):
	if card.isOpen(): return
	
	if player.getNum() >= card.getCost(): 
		player.setNum(card.getCost() * -1)
		card.open()
		updateUI()
		
		selected_secrets.append(card.getSecret())
		acquired_secrets.append(card.getSecret())
			
func reset():
	if button_container == null: return
	
	selected_secrets = []
	player_coin.text = str(player.getNum())
	cur_secrets = getAvailableSecrets()
	
	for i in button_container.get_child_count():
		var card = button_container.get_child(i)
		
		card.init(cur_secrets[i])
		card.setAffordable(player.getNum() >= card.getCost())	

func updateUI():
	player_coin.text = str(player.getNum())
	
	for i in button_container.get_child_count():
		var card = button_container.get_child(i)
		
		card.setAffordable(player.getNum() >= card.getCost())	

func getAcquiredSecrets(): return acquired_secrets

func getAvailableSecrets():
	var temp_secrets = upgrades_data.secrets.duplicate(true)
	var list = []
	
	for button in button_container.get_children():
		var index = randi() % temp_secrets.size()
		var secret = temp_secrets[index]
		
		list.append(secret)
		temp_secrets.remove_at(index)
		
	return list

func _on_continue_pressed() -> void:
	emit_signal('continue_pressed', selected_secrets)

func _on_visibility_changed() -> void:
	if visible: reset()
		
