extends PlantBase
class_name GraveBuster

@export var is_eat_grave := false
@onready var gpu_particles_2d: GPUParticles2D = $Body/GPUParticles2D

var plant_cell : PlantCell

func _ready() -> void:
	super._ready()
	start_eat_grave()


func start_eat_grave():
	is_eat_grave = true
	$Gravebusterchomp.play()
	
	plant_cell = get_parent()
	plant_cell.start_tombstone()

	await get_tree().create_timer(0.5).timeout
	gpu_particles_2d.emitting = true
	gpu_particles_2d.visible = true

func _end_eat_grave():
	plant_cell.delete_tombstone()
	
	child_node_change_parent(gpu_particles_2d, get_parent())
	gpu_particles_2d.emitting = false
	
	_plant_free()
