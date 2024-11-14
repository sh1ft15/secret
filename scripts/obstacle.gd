extends Area2D

@onready var animator = $AnimationPlayer
@onready var label = $Label
@onready var sprite = $Sprite2D

var is_hit = false
var health = 5
var stats = {}

func _ready() -> void:
	animator.play('idle')

func init(p_stats):
	stats = p_stats
	sprite.texture = stats.sprite
	health = stats.health
	label.text = str(health)

func triggerHit():
	is_hit = true
	health = max(health - 1, 0)
	label.text = str(health)
	
	animator.play('hurt')
	
	if health <= 0: 
		get_tree().current_scene.spawnHitParticle(position, 'blood')
		sprite.modulate = Color(1, .1, .1)
		await get_tree().create_timer(.4).timeout
		queue_free()
	else:
		get_tree().current_scene.spawnHitParticle(position, 'leave')
		await get_tree().create_timer(.4).timeout
		is_hit = false
		animator.play('idle')
		sprite.modulate = Color.WHITE

func _on_body_entered(body: Node2D) -> void:
	if is_hit: return
	if body.is_in_group('enemy'): 
		triggerHit()
		if stats.reflect_damage: body.triggerHit(false)
			
		
			
		
