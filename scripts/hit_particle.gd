extends GPUParticles2D

@onready var hit_texture = load("res://sprites/hit_particle.tres")
@onready var blood_texture = load("res://sprites/circle_64.png")
@onready var leave_texture = load("res://sprites/leave.png")
@onready var common_texture = load("res://sprites/common.png")

func start(type):
	if type == 'blood': texture = blood_texture
	elif type == 'leave': texture = leave_texture
	else: texture = common_texture
	restart()

func _on_timer_timeout() -> void:
	queue_free()
