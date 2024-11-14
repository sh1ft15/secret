extends Area2D

@onready var bullet_prefab = load("res://scenes/bullet.tscn") 
@onready var label = $Label
@onready var sprite = $Icon
@onready var animator = $AnimationPlayer
@onready var bullet_timer = $BulletTimer
@export var heart_label : Label
@export var cursor : Area2D

var is_hit = false
var is_death = false

var max_health = 5
var health = 5
var max_num = 10
var cur_num = 0

func _ready() -> void:
	var viewport_size = get_viewport_rect().size
	
	animator.play('idle')
	
	position = Vector2(viewport_size.x / 2 - 20, (viewport_size.y / 2) - 20)
	heart_label.text = 'LIFE : ' + str(health)

func setNum(num):
	if cur_num >= max_num: return
	
	cur_num = max(min(cur_num + num, max_num), 0)
	label.text = str(cur_num) 
	label.modulate = Color.GREEN if cur_num >= max_num else Color.WHITE
	
	updateCards()

func getNum(): return cur_num

func isDeath(): return is_death

func triggerHit():
	is_hit = true
	sprite.modulate = Color(1, 0, 0, .7)
	
	await get_tree().create_timer(2).timeout
	
	sprite.modulate = Color.WHITE
	is_hit = false

func shootBullet(target_position):
	if target_position == null: return
	
	var bullet = bullet_prefab.instantiate()
	var direction = (target_position - global_position).normalized()
	
	get_tree().current_scene.add_child(bullet)
	
	bullet.position = global_position
	
	bullet.velocity = direction * bullet.speed
	bullet.rotation = direction.angle()

func isInViewPort(post):
	return get_viewport_rect().has_point(post)

func updateCards():
	var cards = get_tree().get_nodes_in_group('card')
	for card in cards: 
		card.updateAvailable(cur_num >= card.getCost())

func _on_body_entered(body: Node2D) -> void:
	if is_hit: return
	if body.is_in_group('enemy'):
		if !is_hit: 
			health = max(health - 1, 0)
			heart_label.text = 'LIFE : ' + str(health)
			triggerHit()
			
		if health <= 0: is_death = true

func _on_bullet_timer_timeout() -> void:
	var enemies = get_tree().get_nodes_in_group('enemy')
	var max_dist = 500
	var target_post
	
	for enemy in enemies: 
		var cur_dist = position.distance_to(enemy.position)
		
		if cur_dist < max_dist && isInViewPort(enemy.position):
			max_dist = cur_dist
			target_post = enemy.position
			
	shootBullet(target_post)			
	bullet_timer.start()
