extends BeAttackedBoxComponent
## 僵尸被被攻击盒子组件
class_name BeAttackedBoxComponentZombie

## 本体受击框
@onready var area_2d: Area2D = $Area2D
## 攻击时出现的受击框（大嘴花、窝瓜可以检测到）
@onready var area_2d_attack_appear: Area2D = $Area2DAttackAppear
## 攻击检测射线组件
@onready var attack_ray_component: AttackRayComponent = %AttackRayComponent

## 攻击时受击框出现
func change_area_attack_appear(value: bool):
	if is_instance_valid(area_2d_attack_appear):
		if value:
			area_2d_attack_appear.position.x = -20
		else:
			area_2d_attack_appear.position.x = 0

## 被魅惑
func owner_be_hypno():
	area_2d.collision_layer = 32
	area_2d_attack_appear.queue_free()
