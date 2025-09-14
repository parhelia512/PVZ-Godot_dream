extends Node
class_name GlobalUtilsClass
## 全局工具脚本


#region 工具方法
# 更换节点父节点
static func child_node_change_parent(child_node:Node2D, new_paret_node:Node):
	# 保存全局变换
	var global_transform = child_node.global_transform

	# 移除并添加到新父节点
	child_node.get_parent().remove_child(child_node)
	new_paret_node.add_child(child_node)

	# 恢复全局变换，保持位置不变
	child_node.global_transform = global_transform


## 求字典value乘积
static func get_dic_product(my_dict:Dictionary) -> float:
	var product = 1.0
	for value in my_dict.values():
		product *= value
	return product

## 列表求和
static func sum_arr(arr: Array[float]) -> float:
	var total = 0.0
	for n in arr:
		total += n
	return total

## 根据当前植物类型和僵尸类型获取当前是植物还是僵尸
func get_character_type(plant_type:Global.PlantType, zombie_type:Global.ZombieType):
	if plant_type == Global.PlantType.Null:
		if zombie_type == Global.ZombieType.Null:
			return Global.CharacterType.Null
		else:
			return Global.CharacterType.Zombie
	else:
		return Global.CharacterType.Plant

## 补全列表
func pad_array(arr: Array, target_size: int, pad_value = 0) -> Array:
	while arr.size() < target_size:
		arr.append(pad_value)
	return arr

func world_to_screen(global_pos : Vector2) -> Vector2:
	# pos 是 world / canvas 坐标，也就是某个 Node2D 的 global_position
	var viewport := get_viewport()
	# 获取视口变换 （画布 -> 屏幕）
	var vt : Transform2D = viewport.get_screen_transform()
	# 用 vt * pos 得到屏幕上的像素位置
	return vt * global_pos
#endregion
