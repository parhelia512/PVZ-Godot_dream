extends Node2D
class_name ZombieDropBase


var is_active := false
@export var drop_body : Node2D	

@export var ground_y := 50.0 	# 地面位置
var landed := false 	# 用于判断是否已经着地
var gravity := 500.0	# 重力速度

@export var x_v : float			# x的速度
@export var rotation_speed : float	# 旋转速度
var velocity : Vector2

@export var bounce_damping := 0.5  # 弹跳衰减系数（0.5 表示每次弹跳速度减半）
var min_bounce_speed := 30.0  # 小于这个速度就不再反弹
var shake_intensity := 5.0  # 初始震动强度
var min_rotation_speed := 0.2  # 最小旋转速度


	
func _process(delta):
	if is_active:
		# 应用重力
		velocity.y += gravity * delta
		drop_body.position += velocity * delta
		drop_body.rotation += rotation_speed * delta

		# 逐渐减小旋转速度
		if abs(rotation_speed) >= min_rotation_speed:
			if rotation_speed >= 0:
				rotation_speed -= 0.1 * delta  # 每帧减少一定的旋转速度，逐渐变慢
			else :
				rotation_speed += 0.1 * delta  # 每帧减少一定的旋转速度，逐渐变慢

		# 检查是否到达地面
		if drop_body.position.y >= ground_y:
			drop_body.position.y = ground_y

			if abs(velocity.y) > min_bounce_speed:
				velocity.y = -velocity.y * bounce_damping  # 反弹，速度减弱
				
				# 弹跳时保留震动效果
				shake_intensity = max(0, shake_intensity - 0.2)  # 随着弹跳减少震动强度
			else:
				# 最后一轮反弹后停止移动
				velocity = Vector2.ZERO
				rotation_speed = 0.0
				landed = true
				fade_and_delete()
				


func acitvate_it():
	is_active = true
	visible = true
	move_parent_to_be_sibling()
	
func move_parent_to_be_sibling():
	call_deferred("_deferred_move_parent")
	
# 从僵尸中删除
func _deferred_move_parent():
	var parent := get_parent()
	if parent == null:
		return

	var grandparent := parent.get_parent()
	if grandparent == null:
		return

	# 保持位置
	var global_pos: Vector2 = global_position

	# 真正修改结构
	parent.remove_child(self)
	grandparent.add_child(self)

	# 恢复位置
	self.global_position = global_pos


func fade_and_delete():
	var tween = create_tween()
	tween.tween_property(drop_body, "modulate:a", 0.0, 1.0)  # 1秒内 alpha 从当前变到 0
	tween.tween_callback(Callable(self, "queue_free"))  # 动画完成后删除自身
