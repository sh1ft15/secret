extends CharacterBody2D

@onready var covers = [
	preload("res://sprites/box.png"),
	preload("res://sprites/bush.png")
]

@onready var label = $Label
@onready var agent = $NavigationAgent2D
@onready var sprite = $Base
@onready var cover = $Cover
@onready var animator = $AnimationPlayer
@export var speed = 100

signal death

var is_hit = false
var is_death = false
var has_cover = false
var max_num = 5
var rand_num
var max_dist
var player
var cursor

func _ready() -> void:
	rand_num = randi() % max_num + 1 
	label.text = str(rand_num)	
	sprite.frame = rand_num - 1
	player = get_tree().get_first_node_in_group('player')
	cursor = get_tree().get_first_node_in_group('cursor')
	max_dist = position.distance_to(player.position)
	
	setupCover()

func getNum(): return rand_num

func triggerHit(player):
	if is_hit or is_death: return
	
	is_hit = true
	
	if has_cover: checkCover() 
	else:
		rand_num -= 1
		sprite.frame = max(rand_num - 1, 0)
		label.text = str(rand_num) if rand_num > 0 else ''
	
		if player and checkMatches(): return
	
		if rand_num <= 0: 
			get_tree().current_scene.spawnHitParticle(position, 'blood')
			sprite.modulate = Color(1, .1, .1)
		else: get_tree().current_scene.spawnHitParticle(position, 'hit')
	
	animator.play('hurt')

	await get_tree().create_timer(.4).timeout
	
	if rand_num <= 0: 
		emit_signal('death')
		queue_free()
	else:
		is_hit = false
		sprite.modulate = Color.WHITE
	
func triggerMatch():
	if has_cover: return
	
	is_death = true
	sprite.modulate = Color.GREEN
	animator.play('hurt')
	get_tree().current_scene.spawnHitParticle(position, 'hit')
	
	await get_tree().create_timer(.1).timeout
	
	emit_signal('death')
	queue_free()

func checkMatches():	
	var enemies = get_tree().get_nodes_in_group('enemy')
	var matches = []
	
	for enemy in enemies: 
		if position.distance_to(enemy.position) <= 200:
			if enemy.getNum() == rand_num: matches.append(enemy)

	if matches.size() > 1:
		var match_count = 0
		
		for enemy in matches: 
			enemy.triggerMatch()
			match_count += 1
			
		player.setNum(match_count)
			
		return true
	else: return false

func checkObstacles():
	var obstacles = get_tree().get_nodes_in_group('obstacle')
	var dist_to_player = position.distance_to(player.position)
	var target_post = null
	
	for obstacle in obstacles:
		if position.distance_to(obstacle.position) <= dist_to_player:
			return obstacle.position
			
	return null		
	
func setupCover():
	has_cover = false # randf() <= .5 
	cover.visible = has_cover
	
	if has_cover: 
		cover.get_node("Sprite").texture = covers[0 if randf() <= .5  else 1]
	
func hasCover(): return has_cover

func checkCover():
	var cover_sprite = cover.get_node("Sprite")
	var cover_type = cover_sprite.texture.resource_path.get_file().get_basename()
	
	if cover_type == 'bush':
		get_tree().current_scene.spawnHitParticle(cover.global_position, 'leave')
	else:
		get_tree().current_scene.spawnHitParticle(cover.global_position, 'hit')
	
	has_cover = false
	cover.visible = false

func _physics_process(delta: float) -> void:
	var distance = position.distance_to(player.position)
	var obstacle_post = checkObstacles()
	
	if obstacle_post != null: 
		distance = position.distance_to(obstacle_post)
		agent.set_target_position(obstacle_post)
	else: 
		distance = position.distance_to(player.position)
		agent.set_target_position(player.position)
	
	if distance >= 100:
		var next_position = agent.get_next_path_position()
		var direction = (next_position - position).normalized()
		var intended_velocity = direction * (speed * (distance / max_dist))
		
		agent.set_velocity(intended_velocity)
	else: 
		agent.set_velocity(Vector2.ZERO)

func _on_navigation_agent_2d_velocity_computed(safe_velocity: Vector2) -> void:
	if is_hit or is_death: return
	velocity = safe_velocity
	sprite.flip_h = velocity.x < 0

	animator.play('move' if velocity.length() > 0 else 'idle')
	
	move_and_slide()

func _on_input_event(viewport: Node, event: InputEvent, shape_idx: int) -> void:
	if is_hit or is_death or cursor.isPlacingItem(): return
	if event.is_action_pressed("left_mouse_click"):
		triggerHit(true)

func _on_cover_input_event(viewport: Node, event: InputEvent, shape_idx: int) -> void:
	if is_hit or is_death or cursor.isPlacingItem(): return
	if event.is_action_pressed("left_mouse_click"):
		triggerHit(true)
