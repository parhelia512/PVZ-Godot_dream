extends IronNodeBase
class_name IronNodeOri
##铁器节点,body中的原始铁器

## 铁器中心位置
@export var marker_2d_iron_center: Marker2D

## 被吸走预处理
func preprocessing_be_magnet():
	var diff_pos = global_position - marker_2d_iron_center.global_position
	for child:Node2D in get_children():
		child.visible = true
		child.position += diff_pos
	global_position -= diff_pos
