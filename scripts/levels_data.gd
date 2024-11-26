extends Resource

const levels = [
	
	# high enemy, no armor, no boss
	{
		'required_kills': 150,
		'enemy_max_armor': 1,
		'enemy_cover_rate': 0,
		'max_active_bosses': 0
	},
	
	# moderate enemy, low armor, no boss
	{
		'required_kills': 70,
		'enemy_max_armor': 2,
		'enemy_cover_rate': 0,
		'max_active_bosses': 0
	},
	
	# moderate enemy, no armor, moderate boss
	{
		'required_kills': 70,
		'enemy_max_armor': 1,
		'enemy_cover_rate': 0,
		'max_active_bosses': 2
	},
	
	# low enemy, moderate armor, low boss
	{
		'required_kills': 50,
		'enemy_max_armor': 3,
		'enemy_cover_rate': 0,
		'max_active_bosses': 1
	},
	
	# high enemy, no armor, 1/2 rates, no boss
	{
		'required_kills': 50,
		'enemy_max_armor': 1,
		'enemy_cover_rate': .5,
		'max_active_bosses': 0
	},
	
	# low enemy, high armor, no boss
	{
		'required_kills': 30,
		'enemy_max_armor': 4,
		'enemy_cover_rate': 0,
		'max_active_bosses': 0
	},
	
	# moderate enemy, moderate armor, low boss
	{
		'required_kills': 70,
		'enemy_max_armor': 3,
		'enemy_cover_rate': 0,
		'max_active_bosses': 1
	},
	
	# low enemy, max armor, no boss
	{
		'required_kills': 50,
		'enemy_max_armor': 5,
		'enemy_cover_rate': 0,
		'max_active_bosses': 0
	},
	
	# moderate enemy, low armor, 1/2 cover rates, low boss
	{
		'required_kills': 70,
		'enemy_max_armor': 2,
		'enemy_cover_rate': .5,
		'max_active_bosses': 1
	},
	
	# moderate enemy, moderate armor, 1/2 cover rates, moderate boss
	{
		'required_kills': 70,
		'enemy_max_armor': 4,
		'enemy_cover_rate': .1,
		'max_active_bosses': 2
	},
	
]
