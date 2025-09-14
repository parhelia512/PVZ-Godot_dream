extends Plant000Base
class_name Plant011FumeShroom

@onready var gpu_particles_2d: GPUParticles2D = %GPUParticles2D


func _start_shoot():
	gpu_particles_2d.emitting = true

func _end_shoot():
	gpu_particles_2d.emitting = false

