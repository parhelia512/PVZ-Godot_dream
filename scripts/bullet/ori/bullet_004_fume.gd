extends BulletBase
class_name BulletFume


func _on_area_2d_area_entered(area: Area2D) -> void:
	var zombie :Zombie000Base = area.owner
	## 如果子弹有行属性，需要判断僵尸是否在本行
	if bullet_lane_activate:
		## 如果僵尸在子弹攻击行
		if bullet_lane == zombie.lane:
			_attack_zombie(zombie)
	else:
		_attack_zombie(zombie)
