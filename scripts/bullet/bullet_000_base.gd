extends Node2D
class_name BulletBase
## 直线移动直线基类
@export_group("子弹基础属性")
## 是否已攻击
@export var is_attack := false
## 子弹伤害
@export var attack_value := 20
## 子弹默认移动速度
@export var speed: float = 300.0
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

## 是否激活行属性，激活后只能攻击本行的僵尸
@export var bullet_lane_activate:=true
## 子弹行属性
var bullet_lane :int = -1

@export_group("子弹升级相关")
## 子弹上次升级的植物，寒冰豌豆变成的豌豆子弹无法被上次升级的火炬树桩升级
var bullet_up_plant_last :PlantBase
## 子弹升级需要的植物种类（升级子弹的植物需要有对应的area区域）
@export var bullet_up_plant_type : Global.PlantType = Global.PlantType.TorchWood
## 子弹升级种类（子弹升级后的子弹种类）
@export var bullet_up_type:Global.BulletType

func _ready() -> void:
	# 必须在 ready 后才能安全获取视口尺寸
	screen_rect = get_viewport_rect().grow(500)
		
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
		## 如果子弹有行属性，需要判断僵尸是否在本行
		if bullet_lane_activate:
			## 如果僵尸在子弹攻击行
			if bullet_lane == zombie.lane:
				is_attack = true
				_attack_zombie(zombie)
		else:
			is_attack = true
			_attack_zombie(zombie)


## 攻击一次僵尸
func _attack_zombie(zombie:ZombieBase):
	#攻击
	zombie.be_attacked_bullet(attack_value, bullet_mode, trigger_be_attack_SFX)
	## 是否有音效
	if type_bullet_SFX != SoundManagerClass.TypeBulletSFX.Null:
		SoundManager.play_bullet_attack_SFX(type_bullet_SFX)
	if bullet_effect:
		bullet_effect_change_parent(bullet_effect)
		bullet_effect.activate_bullet_effect()
	queue_free()

# 更换节点父节点
func bullet_effect_change_parent(bullet_effect:Node2D):
	# 保存全局变换
	var curr_global_position = bullet_effect.global_position

	# 移除并添加到bullet节点
	bullet_effect.get_parent().remove_child(bullet_effect)
	get_parent().add_child(bullet_effect)

	# 恢复全局变换，保持位置不变
	bullet_effect.global_position = curr_global_position


#region 子弹升级相关
## 子弹升级需要新建area节点连接信号
func _on_area_2d_2_area_entered(area: Area2D) -> void:
	## 获取子弹升级植物
	var bullet_up_plant:PlantBase = area.get_parent()
	## 如过是火炬树桩
	if bullet_up_plant as TorchWood:
		## 如果不是上次的火炬树桩
		if bullet_up_plant_last != bullet_up_plant:
			bullet_up_plant_last = bullet_up_plant
			call_deferred("create_new_bullet_up", bullet_up_type)
		

## 创建升级后的子弹
func create_new_bullet_up(new_bullet_up_type:Global.BulletType):
	var new_bullet_up_scenes = Global.get_bullet_scenes(new_bullet_up_type)
	## 子弹升级后更新行属性，上次升级的火炬树桩
	var bullet_up :BulletBase = new_bullet_up_scenes.instantiate()
	## 初始化子弹属性
	bullet_up.init_bullet(bullet_lane, start_pos)
	bullet_up.bullet_up_plant_last = bullet_up_plant_last
	get_parent().add_child(bullet_up)
	bullet_up.global_position = global_position
	
	queue_free()
	
#endregion
