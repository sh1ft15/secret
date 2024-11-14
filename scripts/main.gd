extends Node2D

@onready var hit_particle_prefab = load("res://scenes/hit_particle.tscn")
@onready var obstacle_prefab = load("res://scenes/obstacle.tscn")
@onready var enemy_prefab = load("res://scenes/enemy.tscn")
@onready var nav_region = $NavigationRegion2D
@onready var player = $Player
@onready var game_over_screen = $CanvasLayer/GameOverScreen
@onready var upgrades_screen = $CanvasLayer/UpgradeScreen
@onready var kills_label = $CanvasLayer/HBoxContainer/ProgressBar

var game_over = false
var max_enemies = 300
var max_active_enemies = 5
var kills = 0
var required_kills = 10

func _ready() -> void:
	kills_label.max_value = required_kills
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
	kills_label.value = kills

func _on_upgrades_continue_pressed() -> void:
	upgrades_screen.visible = false
	game_over = false
	max_active_enemies = 5
	
	required_kills += 5
	kills = 0
	kills_label.max_value = required_kills
	kills_label.value = kills

func _on_restart_pressed() -> void:
	get_tree().reload_current_scene()

func _on_difficulty_timer_timeout() -> void:
	if game_over: return
	if max_active_enemies == 20: return
	
	max_active_enemies = min(max_active_enemies + 5, 20)
