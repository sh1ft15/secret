extends Node2D

@onready var hit_particle_prefab = load("res://scenes/hit_particle.tscn")
@onready var obstacle_prefab = load("res://scenes/obstacle.tscn")
@onready var enemy_prefab = load("res://scenes/enemy.tscn")
@onready var nav_region = $NavigationRegion2D
@onready var game_over_screen = $CanvasLayer/GameOverScreen
@onready var upgrades_screen = $CanvasLayer/SecretScreen
@onready var cards_container = $CanvasLayer/Cards
@onready var kills_bar = $CanvasLayer/ProgressBar
@onready var player = $Player

var game_over = false

var level = 1

var max_enemies = 300
var max_active_enemies = 5

var kills = 0
var required_kills = 5

var enemy_max_armor = 5
var enemy_cur_armor = 2
var enemy_cover_rate = 0

func _ready() -> void:
	kills_bar.max_value = required_kills
	game_over_screen.visible = false
	upgrades_screen.visible = false
	upgrades_screen.connect('continue_pressed', _on_upgrades_continue_pressed)

func _process(delta: float) -> void:
	if game_over: 
		destroyEnemies()
		return
	
	if player.isDeath(): showGameOverScreen()
	
	if kills >= required_kills:showUpgradesScreen()
		
	var active_enemies = get_tree().get_node_count_in_group('enemy')
		
	if (active_enemies < max_active_enemies):
		var spawn_points = get_tree().get_nodes_in_group('spawn_point')
		
		for spawn_point in spawn_points:
			spawnEnemy(spawn_point)

func showGameOverScreen(): 
	game_over = true
	game_over_screen.visible = true

func showUpgradesScreen():
	game_over = true
	upgrades_screen.visible = true

func spawnEnemy(area):
	var rect = area.get_child(0).shape.get_rect()
	var x = randi_range(rect.position.x, rect.position.x + rect.size.x)
	var y = randi_range(rect.position.y, rect.position.y + rect.size.y)
	var random_pos = area.global_position + Vector2(x, y)
	var enemy = enemy_prefab.instantiate()
			
	enemy.position = random_pos
	enemy.connect('death', onEnemyDeath)
	add_child(enemy)
		
	enemy.init(enemy_cur_armor, enemy_cover_rate)
	
func spawnHitParticle(target_post, type):
	var hit_particle = hit_particle_prefab.instantiate()
	
	hit_particle.global_position = target_post
	
	add_child(hit_particle)	
	
	hit_particle.start(type)
	
func spawnSupportUnit(target_post, card):
	var obstacle = obstacle_prefab.instantiate()
	
	obstacle.global_position = target_post
	add_child(obstacle)
	obstacle.init(card.getStats())

func destroyEnemies():
	var active_enemies = get_tree().get_nodes_in_group('enemy')
	
	for enemy in active_enemies: 
		spawnHitParticle(enemy.global_position, 'hit')
		enemy.queue_free() 

func onEnemyDeath():
	player.setNum(1)
	kills += 1
	kills_bar.value = kills

func applyAcquiredSkill(secret):
	if secret == null: return
	
	match secret.slug:
		'increase_health': player.updateHealth(1)
		'increase_shoot_rate': player.updateShootRate(1)
		'increase_shoot_amount': player.updateShootAmount(1)
		
		# unlock new ability
		'cactus','plank': 
			var new_card
			
			for card in cards_container.get_children():
				if secret.slug == card.getSlug():
					new_card = card
					break
			
			if new_card != null: new_card.visible = true

func _on_upgrades_continue_pressed(secret) -> void:
	upgrades_screen.visible = false
	game_over = false
	
	applyAcquiredSkill(secret)
	
	level += 1
	max_active_enemies = 5

	kills = 0
	required_kills += 5
	kills_bar.value = kills
	kills_bar.max_value = required_kills
	
	# every 3rd levels, increase enemy armor
	if level % 3 == 0: enemy_cur_armor = min(enemy_cur_armor + 1, enemy_max_armor)
		
	# every 6th levels, increase chance for enemy to have cover
	if level % 6 == 0: enemy_cover_rate = min(enemy_cover_rate + 0.1, 1)
		
func _on_restart_pressed() -> void:
	get_tree().reload_current_scene()

func _on_difficulty_timer_timeout() -> void:
	if game_over: return
	if max_active_enemies == 20: return
	
	max_active_enemies = min(max_active_enemies + 5, 20)
