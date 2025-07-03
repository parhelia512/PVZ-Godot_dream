extends Node2D
class_name DirtNewZombie

@onready var gpu_particles_2d_2: GPUParticles2D = $GPUParticles2D2
@onready var gpu_particles_2d: GPUParticles2D = $GPUParticles2D


func start_dirt() -> void:
	visible = true
	gpu_particles_2d.emitting = true
	gpu_particles_2d_2.emitting = true
	
	await gpu_particles_2d_2.finished
	queue_free()
	
	
func start_dirt_no_free() -> void:
	visible = true
	gpu_particles_2d.emitting = true
	gpu_particles_2d_2.emitting = true
	
	await gpu_particles_2d_2.finished
	visible = false
