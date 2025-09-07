extends Bullet000Base
class_name BulletLinear000Base
## 直线移动子弹基类

func _process(delta: float) -> void:
	## 每帧移动子弹
	position += direction * speed * delta

	## 移动超过最大距离后销毁，部分子弹有限制
	if global_position.distance_to(start_pos) > max_distance:
		queue_free()

## 改变y位置
func change_y(target_y:float):
	var tween = create_tween()
	var start_y = global_position.y
	tween.tween_method(func(y):
		global_position.y = y,
		start_y,
		target_y,
		0.3).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)
