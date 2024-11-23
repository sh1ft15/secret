extends Area2D

@onready var bullet_prefab = load("res://scenes/bullet.tscn") 
@onready var sprite = $Icon
@onready var animator = $AnimationPlayer
@onready var bullet_timer = $BulletTimer
@export var heart_container: BoxContainer
@export var cursor : Area2D

signal coin_updated(num)

var is_hit = false
var is_death = false

var max_health = 6
var health = 2

var cur_num = 30

var shoot_rate = 1
var shoot_amount = 1

func _ready() -> void:
	animator.play('idle')
	updateHealth(0)

func setNum(num): 
	cur_num = max(cur_num + num, 0)
	emit_signal('coin_updated', cur_num)
	
func getNum(): return cur_num

func updateHealth(num):
	health = max(min(health + num, max_health), 0)
	
	for i in heart_container.get_child_count():
		heart_container.get_child(i).visible = (i + 1) <= health
	
func updateShootRate(num):
	shoot_rate = max(min(shoot_rate + num, 5), 1)
	bullet_timer.wait_time = max(3 - ((shoot_rate / 5) * 3), .5)
	
func updateShootAmount(num):
	shoot_amount = roundi(max(min(shoot_amount + num, 6), 0))

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

func _on_body_entered(body: Node2D) -> void:
	if is_hit || is_death: return
	if body.is_in_group('enemy'):
		updateHealth(-1)
		triggerHit()
		is_death = health <= 0

func _on_bullet_timer_timeout() -> void:
	if cur_num <= 0: return
	
	var enemies = get_tree().get_nodes_in_group('enemy')
	var target_enemies = []
	
	for i in shoot_amount:
		var max_dist = 500
		var target_enemy
		
		for enemy in enemies: 
			var cur_dist = position.distance_to(enemy.position)
			
			if target_enemies.find(enemy) != -1: continue
			
			if cur_dist < max_dist && isInViewPort(enemy.position):
				max_dist = cur_dist
				target_enemy = enemy
		
		if target_enemy != null and cur_num > 0: 
			target_enemies.append(target_enemy)
			shootBullet(target_enemy.position)
			
			setNum(-1)
			get_tree().current_scene.spawnHitRate(position, -1)
