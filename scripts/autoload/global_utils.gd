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
#endregion
