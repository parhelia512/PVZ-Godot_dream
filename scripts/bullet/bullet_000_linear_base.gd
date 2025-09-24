extends Bullet000Base
class_name BulletLinear000Base
## 直线移动子弹基类

func _process(delta: float) -> void:
	## 每帧移动子弹
	position += direction * speed * delta

	## 移动超过最大距离后销毁，部分子弹有限制
	if global_position.distance_to(start_pos) > max_distance:
		queue_free()

## 改变y位置(三线调用)
func change_y(target_y:float):
	var tween = create_tween()
	var start_y = global_position.y
	tween.tween_method(func(y):
		global_position.y = y,
		start_y,
		target_y,
		0.3).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)

## 子弹与敌人碰撞,直线子弹检测是否有斜面,判断是否与斜面碰撞
func _on_area_2d_attack_area_entered(area: Area2D) -> void:
	## 如果是世界层的碰撞
	if area.collision_layer == 1:
		## 线性子弹判断是否攻击到斜坡
		if area.get_parent() is MainGameSlope:
			var slope:MainGameSlope = area.get_parent()
			## 如果方向与斜面法向量夹角小于90度
			if direction.dot(slope.normal_vector_slope) < 0:
				attack_once(null)
		return

	super(area)
