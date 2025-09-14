extends Node2D
class_name BombEffectBase

@onready var gpu_particles_2d: GPUParticles2D = $GPUParticles2D

# 爆炸特效
func activate_bomb_effect():
	visible = true
	gpu_particles_2d.emitting = true
	await get_tree().create_timer(gpu_particles_2d.lifetime).timeout
	queue_free()
