extends ComponentBase
## 被攻击组件
class_name BeAttackedBoxComponent

@onready var hurt_box_real: Area2D = %HurtBoxReal

# 在碰撞区域内修改属性似乎没有作用
### 启用组件
#func enable_component(is_enable_factor:E_IsEnableFactor):
	#super(is_enable_factor)
	#if is_enabling:
		#for area:Area2D in get_children():
			#area.set_deferred("monitorable", true)
#
### 禁用组件
#func disable_component(is_enable_factor:E_IsEnableFactor):
	#print_debug("受击组件")
	#super(is_enable_factor)
	#if not is_enabling:
		#for area:Area2D in get_children():
			#area.set_deferred("monitorable", false)

## 移动真实受击框
func move_y_hurt_box_real(move_y:float):
	hurt_box_real.position.y += move_y
