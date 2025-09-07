extends AttackRayComponent
class_name AttackRayComponentSquash


## 外部需要的组件（攻击行为组件）连接该信号
## 检测到可攻击敌人，可以攻击信号
## 攻击射线检测区域
func _on_area_2d_area_entered(area: Area2D, i) -> void:
	var enemy = area.owner
	if is_lane and lane != enemy.lane:
		return
	#print_debug(owner.name, "检测到攻击敌人：", area.owner.name)
	#prints("敌人是否为僵尸：", enemy is Zombie000Base)
	#if enemy is Zombie000Base:
		#prints("敌人行属性：", enemy.lane, lane == enemy.lane)
		#prints("敌人当前被攻击状态：", enemy.curr_be_attack_status, enemy.curr_be_attack_status & can_attack_zombie_status)
		#prints("可攻击列表：", enemies_can_be_attacked, enemy not in enemies_can_be_attacked)
	if enemy is Plant000Base:
		var enemy_plant:Plant000Base = enemy
		## 如果当前植物可以被僵尸攻击到
		if enemy_plant.curr_be_attack_status & can_attack_plant_status and enemy not in all_ray_area_enenies_can_be_attacked[i]:
			all_ray_area_enenies_can_be_attacked[i].append(enemy)

	#plant.be_zombie_eat(20)
	## 检测到僵尸并且与自己在同一行
	elif enemy is Zombie000Base:
		var enemy_zombie:Zombie000Base = enemy
		## 连接信号僵尸状态变化函数（首次被检测到）
		if not enemy_zombie.signal_status_change.is_connected(_on_enemy_zombie_status_change):
			enemy_zombie.signal_status_change.connect(_on_enemy_zombie_status_change)

		## 如果当前僵尸可以被僵尸攻击到，并且不在可以攻击列表中
		if enemy_zombie.curr_be_attack_status & can_attack_zombie_status and enemy not in all_ray_area_enenies_can_be_attacked[i]:
			## 如果触发倭瓜位置判定## 并且在右边
			if enemy_zombie.is_trigger_squash_pos_judge and enemy_zombie.global_position.x > owner.global_position.x:
				return
			all_ray_area_enenies_can_be_attacked[i].append(enemy)

	need_judge = true
