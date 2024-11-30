extends Panel

const tutorials = [
	{
		'title': 'Open & Close Chest',
		'desc': 'Open chest to shoot out coin. Close chest to gain coin.',
		'video': preload("res://tutorials/set_player_passive.ogv")
	},
	{
		'title': 'Kill Bug',
		'desc': 'Click to kill bug. Cost a coin.',
		'video': preload("res://tutorials/set_bug_death.ogv")
	},
	{
		'title': 'Match Bugs',
		'desc': 'Gain coins by clicking a bug that group together to match them.',
		'video': preload("res://tutorials/set_bug_match.ogv")
	},
	{
		'title': 'Remove Bug\'s Armor',
		'desc': 'Click armored bug to remove its armor. Cost a coin.',
		'video': preload("res://tutorials/set_bug_armor.ogv")
	}
]

var button_entered = preload("res://audios/button_entered.wav")

@onready var audio = $AudioStreamPlayer2D
@onready var video_player = $VBoxContainer/Row/VideoStreamPlayer
@onready var title_label = $HBoxContainer/Title
@onready var desc_label = $VBoxContainer/Desc

var cur_index = 0

func _ready() -> void:
	setup(tutorials[cur_index])
	
func setup(tutorial):
	title_label.text = tutorial.title
	desc_label.text = tutorial.desc
	video_player.stream = tutorial.video
	video_player.play()

func playAudio(stream):
	audio.stream = stream
	audio.play()

func _on_prev_pressed() -> void:
	cur_index = max(cur_index - 1, 0)
	setup(tutorials[cur_index])

func _on_next_pressed() -> void:
	cur_index = min(cur_index + 1, tutorials.size() - 1)
	setup(tutorials[cur_index])

func _on_main_menu_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/menu.tscn")


func _on_prev_mouse_entered() -> void:
	playAudio(button_entered)


func _on_next_mouse_entered() -> void:
	playAudio(button_entered)


func _on_main_menu_mouse_entered() -> void:
	playAudio(button_entered)
