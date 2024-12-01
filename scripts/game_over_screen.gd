extends CenterContainer

@onready var title_label = $PanelContainer/Column/Title
@onready var max_chain_label = $PanelContainer/Column/Scores/MaxChain/Num
@onready var killed_label = $PanelContainer/Column/Scores/BugKilled/Num
@onready var matched_label = $PanelContainer/Column/Scores/BugMatched/Num
@onready var coin_gained_label = $PanelContainer/Column/Scores/GoldGained/Num
@onready var coin_spent_label = $PanelContainer/Column/Scores/GoldSpent/Num

signal restart_pressed

func init(score, complete = false):
	if complete: title_label.text = 'Stage completed'
	else: title_label.text = 'Game over'
	
	max_chain_label.text = str(score.max_chain)
	killed_label.text = str(score.killed)
	matched_label.text = str(score.matched)
	coin_gained_label.text = str(score.coin_gained)
	coin_spent_label.text = str(abs(score.coin_spent))


func _on_restart_pressed() -> void:
	emit_signal('restart_pressed')
