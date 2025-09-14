extends ZombieBase
class_name ZombieSnorkle

@export var move_use_ground := true
## 游泳速度原始
@export var speed_swimming :float = 20.0
## 游泳速度当前
@export var curr_speed_swimming :float

func _ready() -> void:
	super._ready()
	curr_speed_swimming = speed_swimming


func _process(delta):
	_zombie_walk(delta)
	# 每帧检查射线是否碰到植物
	if ray_cast_2d.is_colliding():
		# 获取Area2D的父节点
		var collider = ray_cast_2d.get_collider()
		if collider:
			_curr_character = collider.get_parent()
		## 在泳池中可以攻击
		if not is_attack and is_swimming:
			start_attack()
		
	else:
		if is_attack:
			end_attack()

## 潜水僵尸被减速时同时更新在水中的移动速度
func update_anim_speed_scale(animation_speed, is_norm=true):
	animation_tree.set("parameters/TimeScale/scale", animation_speed)
	curr_speed_swimming = animation_speed * speed_swimming

## 重写潜水僵尸移动
func _zombie_walk(delta):
	# 检查状态变化,若动画改变，更新_walking_start()
	state_transition_judge_walking_status()

	## 检查是否移动,is_bomb_death不移动
	if is_walk and not is_bomb_death:
		if move_use_ground:
			## 如果不在水中死亡，直接删除
			if is_death:
				delete_zombie()
			if walking_status == WalkingStatus.end:
				_previous_ground_global_x = _ground.global_position.x
			elif walking_status == WalkingStatus.start:
				## 等待1帧，避免僵尸闪现
				await get_tree().process_frame
				walking_status = WalkingStatus.walking
				_previous_ground_global_x = _ground.global_position.x
			else:
				_walk()
		else:
			## 移动距离为 方向*速度*时间
			position.x -= scale.x * curr_speed_swimming * delta

## 动画调用函数
## 从水中起来攻击植物,修改碰撞器层数
func up_to_attack_start():
	area2d.collision_layer = 4

## 攻击完植物后潜入水里
func down_to_pool():
	if not is_death:
		area2d.collision_layer = 1024
	
	

## 落水时水花
func jump_to_pool_splash():
	# 水花
	var splash = Global.splash_pool_scenes.instantiate()
	add_child(splash)
	
	for sprite in swimming_fade:
		sprite.visible = false
	for sprite in swimming_appear:
		sprite.visible = true


## 跳入泳池
func jump_to_pool_end():
	move_use_ground = false
	# 设置碰撞层
	area2d.collision_layer = 1024
	
	
## 碰到泳池碰撞器
func start_swim():
	if not is_death:
		is_swimming = true
		# 设置碰撞层
		area2d.collision_layer = 16
		
## 结束游泳
func end_swim():
	if is_death:
		return
	# 水花
	var splash = Global.splash_pool_scenes.instantiate()
	add_child(splash)
	
	for sprite in swimming_fade:
		sprite.visible = true
	for sprite in swimming_appear:
		sprite.visible = false
	
	body.position.x -= 30
	area2d.position.x = 0
	
	is_swimming = false
	move_use_ground = true

	# 设置碰撞层
	area2d.collision_layer = 4
