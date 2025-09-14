extends IronNodeBase
class_name IronNodeCopy

## 原始精灵节点
@export var all_ori_nodes:Array[Node2D]

## 被吸走预处理
func preprocessing_be_magnet():
	for node in all_ori_nodes:
		node.visible = false
