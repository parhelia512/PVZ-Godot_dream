extends CharacterBase
class_name PlantBase

var be_shovel_look_color := Color(1, 1, 1)
@onready var bullets: Node2D = get_tree().current_scene.get_node("Bullets")



# 重写父类改变颜色方法
func _update_modulate():
	var final_color = base_color * _hit_color * debuff_color * be_shovel_look_color
	self.modulate = final_color

# 被铲子威胁
func be_shovel_look():
	be_shovel_look_color = Color(2, 2, 2)
	_update_modulate()
	
# 被铲子威胁结束
func be_shovel_look_end():
	be_shovel_look_color = Color(1, 1, 1)
	_update_modulate()


# 被攻击
func be_attacked(attack_value:int):
	curr_Hp -= attack_value
	body_light()
	judge_status()
	
func judge_status():
	if curr_Hp <= 0:
		_plant_free()

# 植物死亡
func _plant_free():
	var parent = get_parent()
	if parent is PlantCell:
		var plantcell := parent as PlantCell
		plantcell.is_plant = false
		plantcell.plant = null
	self.queue_free()
	
# 铲掉植物
func be_shovel_kill():
	_plant_free()
	

# 更换节点父节点
func bomb_effect_change_parent(bomb_effect:Node2D):
	# 保存全局变换
	var global_transform = bomb_effect.global_transform

	# 移除并添加到bullet节点
	bomb_effect.get_parent().remove_child(bomb_effect)
	bullets.add_child(bomb_effect)

	# 恢复全局变换，保持位置不变
	bomb_effect.global_transform = global_transform
