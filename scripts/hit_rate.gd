extends Node2D

@onready var label = $HBox/Label
@onready var sprite = $HBox/TextureRect
@onready var anim = $Anim

func init(num, sprite = null):
	anim.play('idle')
	label.text = ('+' if num > 0 else '-') + str(abs(num))

func _on_timer_timeout() -> void:
	queue_free()
