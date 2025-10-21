extends AttackComponentBulletBase
class_name AttackComponentBulletPultBase
## 投手类子弹攻击组件

## 最后一个目标敌人位置
var last_target_enemy_global_pos :Vector2
var last_target_enemy:Character000Base
## 每次攻击时,先更新最前面敌人
## 攻击间隔后触发执行攻击
func _on_bullet_attack_cd_timer_timeout() -> void:
	last_target_enemy = attack_ray_component.update_first_enemy()

	if is_instance_valid(last_target_enemy):
		last_target_enemy_global_pos = last_target_enemy.global_position
		# 在这里调用实际攻击逻辑
		animation_tree.set(attack_para, AnimationNodeOneShot.ONE_SHOT_REQUEST_FIRE)


## 特殊子弹初始化
func special_bullet_init(bullet:Bullet000Base):
	if bullet is Bullet000ParabolaBase:
		if not is_instance_valid(last_target_enemy):
			last_target_enemy = null
		## 抛物线子弹初始化
		bullet.init_bullet_parabola(last_target_enemy, last_target_enemy_global_pos)

