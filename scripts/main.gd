extends Node2D

var hit_particle_prefab = preload("res://scenes/hit_particle.tscn")
var obstacle_prefab = preload("res://scenes/obstacle.tscn")
var enemy_prefab = preload("res://scenes/enemy.tscn")
var boss_prefab = preload("res://scenes/boss.tscn")
var hit_rate_prefab = preload("res://scenes/hit_rate.tscn")
var levels_data = preload("res://scripts/levels_data.gd")

@onready var nav_region = $NavigationRegion2D
@onready var game_over_screen = $CanvasLayer/GameOverScreen
@onready var upgrades_screen = $CanvasLayer/SecretScreen
@onready var option_screen = $CanvasLayer/OptionScreen
@onready var kills_bar = $CanvasLayer/ProgressBar
@onready var combo_counter = $CanvasLayer/ComboCounter
@onready var wave_counter = $CanvasLayer/Level/Num
@onready var player_coins_counter = $CanvasLayer/Coins/Num
@onready var bgm_audio = $BackgroundMusic
@onready var player = $Player

var game_over = false

var level = 1

var max_active_enemies = 5
var max_active_bosses = 1

var kills = 0
var required_kills = 50

var enemy_max_armor = 5
var enemy_cur_armor = 2
var enemy_cover_rate = 0

var settings = {
	'sfx': 1,
	'bgm': 1
}

var score = {
	'wave': 1,
	'max_chain': 0,
	'killed': 0,
	'matched': 0,
	'coin_gained': 0,
	'coin_spent': 0
}

func _ready() -> void:
	applyLevelStats()
	
	bgm_audio
	kills_bar.max_value = required_kills
	combo_counter.visible = false
	game_over_screen.visible = false
	upgrades_screen.visible = false
	
	player.connect('coin_updated', playerCoinUpdated)
	upgrades_screen.connect('continue_pressed', _on_upgrades_continue_pressed)
	game_over_screen.connect('restart_pressed', _on_restart_pressed)
	
	setupOptionScreen()

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("escape"): toggleOptionScreen()

func _process(delta: float) -> void:
	if player.isDeath(): 
		showGameOverScreen()
		return
		
	# spawn normal enemy
	var active_enemies = get_tree().get_node_count_in_group('enemy')
	var active_bosses = get_tree().get_node_count_in_group('boss')
	var spawn_count = min((required_kills - kills), max_active_enemies)
	
	if spawn_count <= 0 and (active_enemies + active_bosses) <= 0: 
		showUpgradesScreen()
	elif ((active_enemies + active_bosses) < spawn_count):
		var spawn_points = get_tree().get_nodes_in_group('spawn_point')
		
		spawn_count = min(spawn_count, spawn_points.size())
		
		for i in spawn_count: spawnEnemy(spawn_points[i])
			

func setupOptionScreen():
	settings.bgm = db_to_linear(bgm_audio.volume_db)
	option_screen.init(settings)
	option_screen.connect('back_pressed', toggleOptionScreen)
	option_screen.connect('sfx_updated', sfxVolumeUpdated)
	option_screen.connect('bgm_updated', bgmVolumeUpdated)

func toggleOptionScreen():
	option_screen.visible = !option_screen.visible

func showGameOverScreen(): 
	game_over = true
	game_over_screen.init(score)
	game_over_screen.visible = true

func showUpgradesScreen():
	game_over = true
	upgrades_screen.visible = true

func isGameOver(): return game_over

func spawnEnemy(area):
	var rect = area.get_child(0).shape.get_rect()
	var x = randi_range(rect.position.x, rect.position.x + rect.size.x)
	var y = randi_range(rect.position.y, rect.position.y + rect.size.y)
	var random_pos = area.global_position + Vector2(x, y)
	var enemy = enemy_prefab.instantiate()
			
	enemy.position = random_pos
	enemy.connect('death', onEnemyDeath)
	enemy.connect('matched', onEnemyMatched)
	enemy.connect('chain_matched', onEnemyChainMatched)
	add_child(enemy)
	enemy.init(enemy_cur_armor, enemy_cover_rate)
			
func spawnBoss(area):
	var rect = area.get_child(0).shape.get_rect()
	var x = randi_range(rect.position.x, rect.position.x + rect.size.x)
	var y = randi_range(rect.position.y, rect.position.y + rect.size.y)
	var random_pos = area.global_position + Vector2(x, y)
	var boss = boss_prefab.instantiate()
	
	boss.position = random_pos
	boss.connect('death', onEnemyDeath)
	add_child(boss)
	
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
	var active_bosses = get_tree().get_nodes_in_group('boss')
	
	if active_enemies.size() > 0:
		for enemy in active_enemies: 
			spawnHitParticle(enemy.global_position, 'hit')
			enemy.queue_free() 
		
	if active_bosses.size() > 0:
		for boss in active_bosses: 
			spawnHitParticle(boss.global_position, 'hit')
			boss.queue_free() 

func onEnemyDeath():
	score.killed += 1
	
	kills += 1
	kills_bar.value = kills
	
func onEnemyMatched():
	score.matched += 1
	
	kills += 1
	kills_bar.value = kills	
	
func onEnemyChainMatched(size):
	score.max_chain = size if size > score.max_chain else score.max_chain
	
	combo_counter.visible = true
	combo_counter.get_node('Timer').start()
	combo_counter.get_node('Anim').play('idle')
	combo_counter.get_node('Count').text = str(size)
	
	await combo_counter.get_node('Timer').timeout
	
	combo_counter.visible = false

func spawnHitRate(post, num):
	var hit_rate = hit_rate_prefab.instantiate()
	
	hit_rate.global_position = post
	
	add_child(hit_rate)
	
	hit_rate.init(num)

func applyAcquiredSkill(secrets):
	if secrets.size() == 0: return
	
	for secret in secrets:
		match secret.slug:
			'increase_health': player.updateHealth(1)
			'increase_shoot_rate': player.updateShootRate(1)
			'increase_shoot_amount': player.updateShootAmount(1)

func playerCoinUpdated(num, increment):
	if increment > 0: score.coin_gained += increment
	elif increment < 0: score.coin_spent += increment
	player_coins_counter.text = str(num)

func applyLevelStats():
	if level <= levels_data.levels.size():
		var data = levels_data.levels[level - 1]
		
		required_kills = data.required_kills
		enemy_cur_armor = min(data.enemy_max_armor, enemy_max_armor)
		enemy_cover_rate = min(data.enemy_cover_rate, 1)
		max_active_bosses = min(data.max_active_bosses, 3)

func sfxVolumeUpdated(volume): settings.sfx = volume

func getSFXVolume(db = false): 
	return linear_to_db(settings.sfx) if db else settings.sfx

func bgmVolumeUpdated(volume):
	bgm_audio.volume_db = linear_to_db(volume)

func _on_upgrades_continue_pressed(secrets) -> void:
	upgrades_screen.visible = false
	game_over = false
	
	level = min(level + 1, 10)
	wave_counter.text = str(level)
	
	applyAcquiredSkill(secrets)
	applyLevelStats()
	
	max_active_enemies = 5
	kills = 0
	kills_bar.value = kills
	kills_bar.max_value = required_kills
		
func _on_restart_pressed() -> void:
	get_tree().reload_current_scene()

func _on_difficulty_timer_timeout() -> void:
	if game_over: return
	if max_active_enemies == 20: return
	
	max_active_enemies = min(max_active_enemies + 5, 20)
	
	# spawn occasional bosses		
	var active_bosses = get_tree().get_node_count_in_group('boss')
	
	if (active_bosses < max_active_bosses):
		var spawn_points = get_tree().get_nodes_in_group('spawn_point')
		
		for i in max_active_bosses:
			spawnBoss(spawn_points[randi_range(0, spawn_points.size() - 1)])

func _on_attack_field_body_entered(body: Node2D) -> void:
	if body.is_in_group('enemy') or body.is_in_group('boss'):
		body.setVunerable(true)

# loop bgm
func _on_background_music_finished() -> void:
	bgm_audio.play()
