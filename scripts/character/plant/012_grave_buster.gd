extends PlantBase
class_name GraveBuster

@export var is_eat_grave := false

var plant_cell : PlantCell

func start_eat_grave():
	is_eat_grave = true
	$Gravebusterchomp.play()
	plant_cell = get_parent()
	plant_cell.start_tombstone()


func _end_eat_grave():
	plant_cell.delete_tombstone()
	_plant_free()
