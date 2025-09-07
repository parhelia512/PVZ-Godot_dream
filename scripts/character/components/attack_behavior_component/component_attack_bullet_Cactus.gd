extends AttackComponentBulletBase
class_name AttackComponentBulletCactus

#TODO:仙人掌攻击气球
## 攻击间隔后触发执行攻击
func _on_bullet_attack_cd_timer_timeout() -> void:
	# 在这里调用实际攻击逻辑
	animation_tree.set("parameters/StateMachine/BlendTree/OneShot/request", AnimationNodeOneShot.ONE_SHOT_REQUEST_FIRE)
