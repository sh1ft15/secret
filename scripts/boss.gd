extends CharacterBody2D

var armor_broken_sound = preload("res://audios/armor_broken.wav")
var bug_death_sound = preload("res://audios/bug_death.wav")
var click_denied_sound = preload("res://audios/click_denied.wav")

@onready var agent = $NavigationAgent2D
@onready var sprite = $Base
@onready var animator = $Anim
@onready var audio = $AudioStreamPlayer2D
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
	rand_num = 6
	setVunerable(is_vunerable)

func getNum(): return rand_num

func triggerHit(click = false):
	if is_hit or is_death: return
	
	is_hit = true
	
	var damage = 1
		
	# no damage for player click if there is no coins
	if click and player.getNum() <= 0: 
		playAudio(click_denied_sound)
		damage = 0
	
	if damage > 0:
		rand_num -= damage
		sprite.frame = max(rand_num - damage, 0)
		
		if click: get_tree().current_scene.spawnHitRate(position, -1)
		
		if rand_num <= 0: 
			get_tree().current_scene.spawnHitParticle(position, 'blood')
			sprite.modulate = Color(1, .1, .1)
			playAudio(bug_death_sound)
		else: 
			get_tree().current_scene.spawnHitParticle(position, 'hit')
			playAudio(armor_broken_sound)
		
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
	
func isVunerable(): return is_vunerable	

func playAudio(stream, volume = 0):
	audio.volume_db = get_tree().current_scene.getSFXVolume(true)
	audio.stream = stream
	audio.play()

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

	animator.play('move' if velocity.length() > 0 else 'idle')
	
	move_and_slide()

func _on_input_event(viewport: Node, event: InputEvent, shape_idx: int) -> void:
	if !is_vunerable or is_hit or is_death: return
	if event.is_action_pressed("left_mouse_click"):
		
		triggerHit(true)
		
		if player.getNum() > 0: player.setNum(-1)
