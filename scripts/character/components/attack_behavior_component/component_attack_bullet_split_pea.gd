extends AttackComponentBulletBase
class_name AttackComponentBulletSplitPea


## 攻击间隔后触发执行攻击
func _on_bullet_attack_cd_timer_timeout() -> void:
	# 在这里调用实际攻击逻辑
	animation_tree.set("parameters/OneShot/request", AnimationNodeOneShot.ONE_SHOT_REQUEST_FIRE)
	animation_tree.set("parameters/OneShot 2/request", AnimationNodeOneShot.ONE_SHOT_REQUEST_FIRE)


func set_cancel_attack():
	animation_tree.set("parameters/OneShot/request", AnimationNodeOneShot.ONE_SHOT_REQUEST_NONE)
	animation_tree.set("parameters/OneShot 2/request", AnimationNodeOneShot.ONE_SHOT_REQUEST_NONE)


## 发射子弹（动画调用）
func _shoot_bullet():
	var marker_2d_bullet = markers_2d_bullet[0]
	var ray_direction = attack_ray_component.ray_area_direction[0]
	var bullet:Bullet000Base = Global.get_bullet_scenes(attack_bullet_type).instantiate()
	## 子弹初始位置
	var bullet_pos_ori = marker_2d_bullet.global_position
	bullet.init_bullet(owner.lane, bullets.to_local(bullet_pos_ori), ray_direction)
	bullets.add_child(bullet)
	play_throw_sfx()

## 发射子弹2（动画调用）
func _shoot_bullet_2():
	var marker_2d_bullet = markers_2d_bullet[1]
	var ray_direction = attack_ray_component.ray_area_direction[1]
	var bullet:Bullet000Base = Global.get_bullet_scenes(attack_bullet_type).instantiate()
	## 子弹初始位置
	var bullet_pos_ori = marker_2d_bullet.global_position
	bullet.init_bullet(owner.lane, bullets.to_local(bullet_pos_ori), ray_direction)
	bullets.add_child(bullet)
	play_throw_sfx()
