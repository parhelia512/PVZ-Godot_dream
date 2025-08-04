extends BulletBase
class_name BulletWallNutBowling

var rotation_speed = 5.0  # 旋转速度
var zombie_manager:ZombieManager
var y_every_lane:Array[float]
var first_attack_end := false	## 第一次攻击是否完成
var in_curr_lane := true
var curr_zombie :ZombieBase


func _ready() -> void:
	super._ready()
	zombie_manager = get_tree().current_scene.get_node("Manager/ZombieManager")
	for i_zombie_row_node:Node2D in zombie_manager.zombies_row_node:
		y_every_lane.append(i_zombie_row_node.global_position.y)
	SoundManager.play_bullet_attack_SFX(SoundManager.TypeBulletSFX.Bowling)
	

func _process(delta: float) -> void:
	super._process(delta)
	bullet_body.rotation += rotation_speed * delta
	## 如果第一次攻击已完成，碰到边缘时
	if first_attack_end:
		## INFO:由于帧率不同，可能调用多次，需注意，已解决
		## 如果超过第0行
		if global_position.y < y_every_lane[0]:
			bullet_lane = 0
			_update_direction()
		## 如果超过第最后一行
		if global_position.y > y_every_lane[-1] + 5:
			bullet_lane = y_every_lane.size() - 1
			_update_direction()
	
	# 如果到达目标行
	if not in_curr_lane and (y_every_lane[bullet_lane] - 10 < global_position.y and global_position.y < y_every_lane[bullet_lane] + 10):
		## 查看是否有僵尸在攻击范围内
		if curr_zombie:
			var lane_zombie = curr_zombie.lane
			## 如果僵尸在子弹攻击行
			if bullet_lane == lane_zombie:
				_attack_zombie(curr_zombie)
				_update_direction()
		else:
			is_attack = false	# 修改当前行为未攻击
			in_curr_lane = true
		
	## 移动离开当前行后，更新当前
	if in_curr_lane and (y_every_lane[bullet_lane] - 10 > global_position.y or global_position.y > y_every_lane[bullet_lane] + 10):
		in_curr_lane = false	# 修改当前行
		_update_direction(false)
		
		
func update_z_index_and_lane(curr_lane:int, target_lane:int):
	#第0行僵尸z_index = 410
	if curr_lane > target_lane:
		z_index = 415 + target_lane * 10
	else:
		z_index = 415 + (target_lane - 1) * 10
	bullet_lane = target_lane

## 第一次子弹击中僵尸,或到达当前行后第一次击中僵尸
func _on_area_2d_area_entered(area: Area2D) -> void:
	## 在当前行并且未攻击时
	if in_curr_lane and not is_attack:
		var zombie :ZombieBase = area.get_parent()
		var lane_zombie = zombie.lane
		## 如果僵尸在子弹攻击行
		if bullet_lane == lane_zombie:
			## 攻击后修改为不再当前行，并已攻击
			in_curr_lane = false
			is_attack = true
			_attack_zombie(zombie)
			_update_direction()
			first_attack_end = true
			bullet_mode = Global.AttackMode.BowlingSide
		
	else :
		curr_zombie = area.get_parent()

## 更新保龄球移动方向，越过行时仅更新图层和行属性
func _update_direction(change:bool = true):
	if change:
		if direction.y == 0:
			if bullet_lane == 0:
				direction.y = 1
			elif bullet_lane == zombie_manager.zombies_row_node.size() - 1:
				direction.y = -1
			else:
				direction.y = 1 if randf() > 0.5 else -1
		else:
			if bullet_lane == 0:
				direction.y = 1
			elif bullet_lane == y_every_lane.size() - 1:
				direction.y = -1
			else:
				direction.y *= -1
			
	if bullet_lane + direction.y == 5:
		get_tree().paused = true
	update_z_index_and_lane(bullet_lane, bullet_lane + direction.y)
	
	
func _on_area_2d_area_exited(area: Area2D) -> void:
	if curr_zombie == area.get_parent():
		curr_zombie = null

## 重写攻击，攻击后不删除
func _attack_zombie(zombie:ZombieBase):
	#攻击
	zombie.be_attacked_bullet(attack_value, bullet_mode, trigger_be_attack_SFX)
	## 是否有音效
	if type_bullet_SFX != SoundManagerClass.TypeBulletSFX.Null:
		SoundManager.play_bullet_attack_SFX(type_bullet_SFX)
	if bullet_effect:
		bullet_effect_change_parent(bullet_effect)
		bullet_effect.activate_bullet_effect()
