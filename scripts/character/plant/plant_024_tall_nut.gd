extends Plant000Base
class_name Plant024TallNut


func _on_area_2d_stop_jump_area_entered(area: Area2D) -> void:
	var zombie:Zombie000Base = area.owner
	if zombie.is_trigger_tall_nut_stop_jump:
		zombie.jump_be_stop(self)

