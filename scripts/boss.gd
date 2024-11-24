extends CharacterBody2D

@onready var armor_pieces = $ArmorPieces
@onready var agent = $NavigationAgent2D
@onready var sprite = $Base
@onready var animator = $Anim
@export var speed = 50

signal death

var is_vunerable = false
var is_hit = false
var is_death = false
var rand_num
var max_dist
var player

func _ready() -> void:
	player = get_tree().get_first_node_in_group('player')
	max_dist = position.distance_to(player.position)
	rand_num = armor_pieces.get_child_count() + 1
	setVunerable(is_vunerable)

func getNum(): return rand_num

func triggerHit(click = false):
	print('test')
	if is_hit or is_death: return
	
	is_hit = true
	
	var damage = 1
		
	# no damage for player click if there is no coins
	if click and player.getNum() <= 0: damage = 0
	
	if damage > 0:
		rand_num -= damage
		
		if click: get_tree().current_scene.spawnHitRate(position, -1)
		
		var intact_armor_pieces = armor_pieces.get_children().filter(func(item): 
			return item.visible
		)
		
		if intact_armor_pieces.size() > 0:
			var index = randi_range(0, intact_armor_pieces.size() - 1)
			
			intact_armor_pieces[index].visible = false
			get_tree().current_scene.spawnHitParticle(position, 'hit')
		else:
			get_tree().current_scene.spawnHitParticle(position, 'blood')
			sprite.modulate = Color(1, .1, .1)
			
	animator.play('hurt')

	await get_tree().create_timer(.4).timeout
	
	if rand_num <= 0: 
		emit_signal('death')
		queue_free()
	else:
		is_hit = false
		sprite.modulate = Color.WHITE

func setVunerable(status): 
	is_vunerable = status
	sprite.modulate = Color.WHITE if status else Color(1, 1, 1, .5)
	
	for piece in armor_pieces.get_children(): 
		piece.modulate = Color.WHITE if status else Color(1, 1, 1, .5)
	
func isVunerable(): return is_vunerable	

func _physics_process(delta: float) -> void:
	var distance = position.distance_to(player.position)
	
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
	
	for piece in armor_pieces.get_children(): piece.flip_h = velocity.x < 0

	animator.play('move' if velocity.length() > 0 else 'idle')
	
	move_and_slide()

func _on_input_event(viewport: Node, event: InputEvent, shape_idx: int) -> void:
	if !is_vunerable or is_hit or is_death: return
	if event.is_action_pressed("left_mouse_click"):
		
		triggerHit(true)
		
		if player.getNum() > 0: player.setNum(-1)
