extends Plant000Base
class_name Plant024TallNut



func _on_area_2d_stop_jump_area_entered(area: Area2D) -> void:
	var zombie:Zombie000Base = area.owner
	if zombie.curr_be_attack_status == Zombie000Base.E_BeAttackStatusZombie.IsJump:
		zombie.jump_be_stop(self)
