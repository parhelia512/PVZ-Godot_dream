extends Node2D
class_name BulletLineraBase
## 直线移动直线基类

## 是否已攻击
@export var is_attack := false
## 子弹伤害
@export var attack_value := 20
## 子弹默认移动速度
@export var speed: float = 400.0
## 子弹默认移动方向
@export var direction: Vector2 = Vector2.RIGHT
## 子弹模式：普通，穿透，真实
@export var bullet_mode : Global.AttackMode
## 是否触发受击音效
@export var trigger_be_attack_SFX := true
## 子弹本身是否有音效
@export var type_bullet_SFX :SoundManagerClass.TypeBulletSFX =  SoundManagerClass.TypeBulletSFX.Pea

## 子弹击中特效
@export var bullet_effect: Node2D
## 子弹移动离出生点最大距离，超过自动销毁
@export var max_distance := 2000.0
## 子弹初始位置
var start_pos: Vector2
## 超出屏幕500像素删除
var screen_rect: Rect2 

## 子弹行属性
var bullet_lane :int = -1



func _ready() -> void:
	# 必须在 ready 后才能安全获取视口尺寸
	screen_rect = get_viewport_rect().grow(500)
	# 安全获取BulletEffect节点并验证类型
	if has_node("BulletEffect"):
		var effect_node = $BulletEffect
		bullet_effect = effect_node

	else:
		# 可以选择禁用子弹效果或使用默认值
		bullet_effect = null
		
## 初始化子弹属性
func init_bullet(lane:int, start_pos:Vector2):
	## 子弹行是十进制，
	bullet_lane = lane
	self.start_pos = start_pos


func _process(delta: float) -> void:
	# 每帧移动子弹
	position += direction * speed * delta
	
	## 移动超过最大距离后销毁，部分子弹有限制
	if global_position.distance_to(start_pos) > max_distance:
		queue_free()
	
	## 超过屏幕500像素销毁
	if not screen_rect.has_point(global_position):
		queue_free()

## 改变y位置
func change_y(target_y:float):
	var tween = get_tree().create_tween()
	var start_y = global_position.y
	tween.tween_method(func(y): 
		global_position.y = y,
		start_y, 
		target_y, 
		0.3).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)

## 子弹击中僵尸
func _on_area_2d_area_entered(area: Area2D) -> void:
	if not is_attack:
		var zombie :ZombieBase = area.get_parent()
		## 如果僵尸在子弹攻击行
		if bullet_lane == zombie.lane:
			is_attack = true
			_attack_zombie(zombie)
			if bullet_effect:
				bullet_effect_change_parent(bullet_effect)
				bullet_effect.activate_bullet_effect()
			queue_free()

## 攻击一次僵尸
func _attack_zombie(zombie:ZombieBase):
	var lane_zombie = zombie.lane
		#攻击
	zombie.be_attacked_bullet(attack_value, bullet_mode, trigger_be_attack_SFX)
	## 是否有音效
	if type_bullet_SFX != SoundManagerClass.TypeBulletSFX.Null:
		SoundManager.play_bullet_attack_SFX(type_bullet_SFX)

# 更换节点父节点
func bullet_effect_change_parent(bullet_effect:Node2D):
	# 保存全局变换
	var curr_global_position = bullet_effect.global_position

	# 移除并添加到bullet节点
	bullet_effect.get_parent().remove_child(bullet_effect)
	get_parent().add_child(bullet_effect)

	# 恢复全局变换，保持位置不变
	bullet_effect.global_position = curr_global_position
