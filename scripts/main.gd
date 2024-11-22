extends Node2D

@onready var hit_particle_prefab = load("res://scenes/hit_particle.tscn")
@onready var obstacle_prefab = load("res://scenes/obstacle.tscn")
@onready var enemy_prefab = load("res://scenes/enemy.tscn")
@onready var nav_region = $NavigationRegion2D
@onready var game_over_screen = $CanvasLayer/GameOverScreen
@onready var upgrades_screen = $CanvasLayer/SecretScreen
@onready var kills_bar = $CanvasLayer/ProgressBar
@onready var combo_counter = $CanvasLayer/ComboCounter
@onready var wave_counter = $CanvasLayer/Level/Num
@onready var player_coins_counter = $CanvasLayer/Coins/Num
@onready var player = $Player

var game_over = false

var level = 1

var max_enemies = 300
var max_active_enemies = 5

var kills = 0
var required_kills = 50

var enemy_max_armor = 5
var enemy_cur_armor = 2
var enemy_cover_rate = 0

func _ready() -> void:
	kills_bar.max_value = required_kills
	combo_counter.visible = false
	game_over_screen.visible = false
	upgrades_screen.visible = false
	
	player.connect('coin_updated', playerCoinUpdated)
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
	enemy.connect('chain_matched', onEnemyChainMatched)
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
	kills += 1
	kills_bar.value = kills
	
func onEnemyChainMatched(size):
	combo_counter.visible = true
	combo_counter.get_node('Timer').start()
	combo_counter.get_node('Anim').play('idle')
	combo_counter.get_node('Count').text = str(size)
	
	await combo_counter.get_node('Timer').timeout
	
	combo_counter.visible = false

func applyAcquiredSkill(secrets):
	if secrets.size() == 0: return
	
	for secret in secrets:
		match secret.slug:
			'increase_health': player.updateHealth(1)
			'increase_shoot_rate': player.updateShootRate(1)
			'increase_shoot_amount': player.updateShootAmount(1)
			
			# unlock new support units
			'cactus','plank': pass

func playerCoinUpdated(num):
	player_coins_counter.text = str(num)

func _on_upgrades_continue_pressed(secrets) -> void:
	upgrades_screen.visible = false
	game_over = false
	
	applyAcquiredSkill(secrets)
	
	level += 1
	wave_counter.text = str(level)
	max_active_enemies = 5

	kills = 0
	required_kills += 25
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

func _on_attack_field_body_entered(body: Node2D) -> void:
	if body.is_in_group('enemy'):
		body.setVunerable(true)
