extends AttackComponentBulletBase
class_name AttackComponentBulletPultBase
## 投手类子弹攻击组件

## 最后一个目标敌人位置
var last_target_enemy_global_pos :Vector2

## 每次攻击时,先更新最前面敌人
## 攻击间隔后触发执行攻击
func _on_bullet_attack_cd_timer_timeout() -> void:
	attack_ray_component.update_first_enemy()
	last_target_enemy_global_pos = attack_ray_component.enemy_can_be_attacked.global_position
	# 在这里调用实际攻击逻辑
	animation_tree.set("parameters/OneShot/request", AnimationNodeOneShot.ONE_SHOT_REQUEST_FIRE)


## 特殊子弹初始化
func special_bullet_init(bullet):
	bullet.init_bullet_parabola(attack_ray_component.enemy_can_be_attacked, last_target_enemy_global_pos)

