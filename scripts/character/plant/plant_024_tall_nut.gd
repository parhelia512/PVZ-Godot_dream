extends WallNut
class_name TallNut


## 检测正在跳跃的撑杆跳或海豚僵尸
func _on_area_2d_2_area_entered(area: Area2D) -> void:
	var zombie:ZombieBase = area.get_parent()
	if zombie is ZombiePoleVaulter:
		var zombie_pole = zombie as ZombiePoleVaulter
		zombie_pole.jump_be_stop(self)
	elif zombie is ZombieDolphinrider:
		var zombie_dolphinrider = zombie as ZombieDolphinrider
		if not zombie_dolphinrider.is_dolphinrider:
			zombie_dolphinrider.jump_be_stop(self)
