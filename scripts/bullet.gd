extends Area2D

@export var speed: float = 500.0

var velocity = Vector2.ZERO

func _process(delta):
	position += velocity * delta

func _on_timer_timeout() -> void:
	queue_free()

func _on_body_entered(body: Node2D) -> void:
	if body.is_in_group('obstacle'): queue_free()
	elif body.is_in_group('enemy'):
		body.triggerHit(false)
		queue_free()
