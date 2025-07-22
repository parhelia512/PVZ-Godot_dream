extends ZombieBase
class_name ZombieDolphinrider

## move_use_ground是否使用ground移动，is_swimming控制动画
@export var move_use_ground := true
## 游泳速度原始
@export var speed_swimming :float = 100.0
## 游泳速度当前
@export var curr_speed_swimming :float
## body是否会到原始位置
@export var is_restore_x_body := true
## body原始position
var position_x_ori_body : float
@onready var area_2d_swim: Area2D = $Area2DSwim

## 是否跳过植物
@export var is_jump := false
## 是否为骑着海豚
@export var is_dolphinrider := true
@onready var ray_cast_2d_2: RayCast2D = $RayCast2D2
var is_jump_stop := false
var jump_stop_postion :Vector2

var is_jump_end := false
var is_death_process := false


func _ready() -> void:
	super._ready()
	curr_speed_swimming = speed_swimming
	position_x_ori_body = body.position.x
	if not is_idle:
		SoundManager.play_zombie_SFX(Global.ZombieType.ZombieDolphinrider, "dolphin_appears")

## 僵尸被减速时同时更新在水中的移动速度
func update_anim_speed_scale(animation_speed, is_norm=true):
	animation_tree.set("parameters/TimeScale/scale", animation_speed)
	curr_speed_swimming = animation_speed * speed_swimming



func _process(delta):
	if is_dolphinrider:
		## 骑着海豚死亡，等待1秒后直接删除
		if is_death:
			if not is_death_process:
				is_death_process = true
				speed_swimming = 0
				curr_speed_swimming = 0
				await get_tree().create_timer(1.0).timeout
				delete_zombie()
			else:
				return
			
		_zombie_walk(delta)
		#骑海豚时检测到植物
		# 每帧检查射线是否碰到植物
		if ray_cast_2d_2.is_colliding():
			if not area2d_free:
				# 设置碰撞层
				area2d.collision_layer = 16
				is_jump = true
				is_dolphinrider = false
				is_walk = true
				walking_status = WalkingStatus.end
				SoundManager.play_zombie_SFX(Global.ZombieType.ZombieDolphinrider, "dolphin_before_jumping")
				
				
	elif is_jump:
		pass
	else:
		super._process(delta)

## 重写僵尸移动
func _zombie_walk(delta):
	# 检查状态变化,若动画改变，更新_walking_start()
	state_transition_judge_walking_status()

	## 检查是否移动,is_bomb_death不移动
	if is_walk and not is_bomb_death:
		## 如果使用ground移动
		if move_use_ground:
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
## 僵尸跳跃完成修改碰撞器层数
func zombie_jump_end():
	if not is_death:
		area2d.collision_layer = 4


## 僵尸跳跃修改碰撞层
func zombie_jump():
	area2d.collision_layer = 16


## 僵尸出场海豚落水时水花
func jump_to_pool_splash():
	# 水花
	var splash = Global.splash_pool_scenes.instantiate()
	add_child(splash)
	splash.position.x = -65.0
	
## 跳跃植物时水花
func shadow_splash():
	# 水花
	var splash = Global.splash_pool_scenes.instantiate()
	add_child(splash)
	splash.global_position.x = shadow.global_position.x


func jump_plant_end():
	is_jump_end = true
	
	await get_tree().process_frame
	await get_tree().process_frame
	
	is_jump = false
	is_walk = true
	move_use_ground = true
	walking_status = WalkingStatus.start

	## 移动本体位置
	position.x -= 176
	body.position.y += 60
	
	is_restore_x_body = true
	zombie_jump_end()
	
## 跳跃被高坚果强行停止
func jump_be_stop(plant:PlantBase):
	is_jump_stop = true
	jump_stop_postion = plant.global_position

func judge_jump_be_stop():
	if is_jump_stop:
		print("被高坚果挡住")
		await jump_plant_end()
		global_position.x = jump_stop_postion.x+20

## 跳入泳池
func jump_to_pool_end():
	move_use_ground = false
	# 设置碰撞层
	zombie_jump_end()
	ray_cast_2d_2.collision_mask = 2
	
## 碰到泳池碰撞器
func start_swim():
	is_swimming = true
	# 设置碰撞层
	area2d.collision_layer = 16


## 结束游泳
func end_swim():
	if is_death:
		return
	for sprite in swimming_fade:
		sprite.visible = true
	for sprite in swimming_appear:
		sprite.visible = false
	## 
	if is_jump_end:
		body.position.y -= 60
		
	if is_jump:
		if not is_jump_end:
			is_jump = false
			is_jump_end = true
			global_position.x = shadow.global_position.x
		else:
			print("跳跃结束")
	else:
		if is_dolphinrider:
			## 骑海豚的身体组成部分与本体位置不同
			global_position.x = shadow.global_position.x
	
	#splash.global_position.x = shadow.global_position.x
	
	# 水花
	var splash = Global.splash_pool_scenes.instantiate()
	add_child(splash)
	
	is_walk = true
	is_swimming = false
	move_use_ground = true
	walking_status = WalkingStatus.start

	# 设置碰撞层
	area2d.collision_layer = 4
