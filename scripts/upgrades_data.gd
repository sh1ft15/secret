extends Resource

const secrets = [
	{
		'slug': 'increase_health', 
		'desc': 'Health +1', 
		'cost_min': 3,
		'cost_max': 10,
		'repeatable': true,
		'sprite': preload('res://sprites/heart.png')
	},
	{
		'slug': 'increase_coin', 
		'desc': 'Coin +10', 
		'cost_min': 3,
		'cost_max': 10,
		'repeatable': true,
		'sprite': preload('res://sprites/coin.png')
	},
	{
		'slug': 'increase_shoot_rate', 
		'desc': 'Shoot Rate +1', 
		'cost_min': 3,
		'cost_max': 10,
		'repeatable': 5,
		'sprite': preload('res://sprites/heart.png')
	},
	{
		'slug': 'increase_shoot_amount', 
		'desc': 'Shoot Amount +1', 
		'cost_min': 3,
		'cost_max': 10,
		'repeatable': 4,
		'sprite': preload('res://sprites/heart.png')
	},
	{
		'slug': 'upgrade_plank', 
		'desc': 'Increase Plank health by 1', 
		'cost_min': 10,
		'cost_max': 40,
		'repeatable': 5,
		'sprite': preload('res://sprites/plank.png')
	},
	{
		'slug': 'upgrade_cactus', 
		'desc': 'Increase Cactus health by 1', 
		'cost_min': 20,
		'cost_max': 50,
		'repeatable': 5,
		'sprite': preload('res://sprites/cactus.png')
	},
	{
		'slug': 'plank', 
		'desc': 'Can place a plank. It does nothing',
		'cost_min': 10,
		'cost_max': 30,
		'repeatable': false,
		'sprite': preload("res://sprites/plank.png")
	},
	{
		'slug': 'cactus', 
		'desc': 'Can place a cactus. It hurt the bugs',
		'cost_min': 10,
		'cost_max': 50,
		'repeatable': false,
		'sprite': preload("res://sprites/cactus.png")
	}
]
