extends PeaShooterSingle
class_name Cactus

@export var is_rise:= false

# 每次触发执行攻击
func _on_attack_timer_timeout():
	# 在这里调用实际攻击逻辑
	if not is_attack:
		attack_timer.stop()
		return
	if animation_tree:
		print("攻击一次")
		if is_rise:
			animation_tree.set("parameters/StateMachine/BlendTree 2/OneShot/request", AnimationNodeOneShot.ONE_SHOT_REQUEST_FIRE)

		else:
			animation_tree.set("parameters/StateMachine/BlendTree/OneShot/request", AnimationNodeOneShot.ONE_SHOT_REQUEST_FIRE)
		
