extends PeaShooterSingle
class_name SplitPea

@onready var ray_cast_2d_2: RayCast2D = $RayCast2D2

@export var bullet_position_back :Node2D
@export var blink_sprite_list: Array[Sprite2D]	## 控制idle状态下植物眨眼


func _on_blink_timer_timeout():
	## is_blink状态下眨眼
	if is_blink:
		for blink_sprite in blink_sprite_list:
			do_blink(blink_sprite)

## 攻击时停止眨眼
func attack_stop_blink():
	for blink_sprite in blink_sprite_list:
		blink_sprite.visible = false


func judge_ray_zomebie():
	if ray_cast_2d.is_colliding() or ray_cast_2d_2.is_colliding():
		return true
	return false

# 每次触发执行攻击
func _on_attack_timer_timeout():
	# 在这里调用实际攻击逻辑
	if not is_attack:
		attack_timer.stop()
		return
	if animation_tree:
		animation_tree.set("parameters/OneShot/request", AnimationNodeOneShot.ONE_SHOT_REQUEST_FIRE)
		animation_tree.set("parameters/OneShot 2/request", AnimationNodeOneShot.ONE_SHOT_REQUEST_FIRE)
	

func _shoot_bullet_back():
	var bullet:BulletBase = bullet_scene.instantiate()
	## 修改子弹默认移动方向
	bullet.global_position = bullet_position_back.global_position
	bullets.add_child(bullet)
	bullet.init_bullet(row_col.x, bullet.global_position, Vector2.LEFT)
	play_throw_sfx()
