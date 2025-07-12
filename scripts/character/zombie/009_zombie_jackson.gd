extends ZombieBase
class_name ZombieJackson

#extends Node2D

@onready var dancer_manager: DancerManager
var DancerManagerScene := load("res://scenes/manager/dancer_manager.tscn")

## 舞王入场滑步次数
@export var num_moon_walk := 2
var anim_change := false
var anim_custom_blend = false
var animation_player: AnimationPlayer

var is_start_enter := true

var curr_anim_death := false
## 伴舞僵尸编号,舞王为-1
var dancer_id:= -1
## 僵尸朝向， 1为正常朝向，-1为被魅惑的朝向
var direction_scale = Vector2(1,1)

#region 重写父类的方法
func _ready():
	super._ready()
	
	#game_init_zombie_jackson()
	#_init_dance()

func show_init_zombie_jackson():
	var anim = animation_player.get_animation("moonwalk")
	if anim:
		# 设置循环模式
		anim.loop_mode = Animation.LOOP_LINEAR
		
	animation_player.play("moonwalk")
	is_walk = false

func game_init_zombie_jackson():
	var anim = animation_player.get_animation("moonwalk")
	if anim:
		# 设置循环模式
		anim.loop_mode = Animation.LOOP_NONE
	$Dancer.play()
	_init_dance()

## 舞王出场动画，伴舞继承重写
func _init_dance():
	animation_player.set_blend_time('armraise', 'walk', 0.1)
	scale = Vector2(-1,1) * direction_scale
	ray_cast_2d.scale = scale
	label_hp.scale = scale
	
	for i in range(num_moon_walk):
		animation_player.play("moonwalk")
		animation_player.seek(0)
		anim_change = true
		await animation_player.animation_finished
		
	scale *= Vector2(-1,1) * direction_scale
	ray_cast_2d.scale = scale
	label_hp.scale = scale
	
	animation_player.play("point")	
	anim_change = true
	
	dancer_manager.start_anim()


## 舞王开始后移动需要停止两帧不闪现
func _zombie_walk():
	# 检查状态变化,若动画改变，更新_walking_start()
	state_transition_judge_walking_status()
	
	## 检查是否移动,
	if is_walk and not is_bomb_death:
		if walking_status == WalkingStatus.end:
			_previous_ground_global_x = _ground.global_position.x
		elif walking_status == WalkingStatus.start:
			## 等待两帧之后，舞王不闪现，不知道什么原因，等待1帧会闪现
			await get_tree().process_frame
			await get_tree().process_frame
			walking_status = WalkingStatus.walking
			_previous_ground_global_x = _ground.global_position.x
		else:
			_walk()


## 非父类方法
## 舞王入场状态结束后调用方法,召唤僵尸结束后调用方法
func jackson_end_enter():
	
	is_start_enter = false
	
	#如果入场状态结束后未死亡
	if not is_death:
		# 如果攻击状态
		if is_attack:
			start_attack()
		#如果非攻击状态
		else:
			allow_dance()

#region 初始化相关
## 重写初始化节点，没有AnimationTree
func _get_some_node():
	body = $Body
	_ground = $Body/_ground
	dancer_manager = $DancerManager
	animation_player = $AnimationPlayer
	
## 随机初始化动画播放速度(重写父类方法)
func _init_anim_speed():
	# 获取动画初始速度
	animation_origin_speed = animation_player.speed_scale
	animation_speed_random = randf_range(0.9, 1.1)
	animation_origin_speed *= animation_speed_random
	animation_player.speed_scale = animation_origin_speed
	
	dancer_manager._init_anim_speed(animation_origin_speed, self)

	
#endregion

#region 攻击相关
## 新增舞王非入场状态
func judge_can_attack():
	return _curr_character and is_attack and not area2d_free and not is_start_enter

func start_attack():
	
	# 获取Area2D的父节点
	var collider = ray_cast_2d.get_collider()
	_curr_character = collider.get_parent()
	
	is_walk = false
	is_attack = true
	
	dancer_manager.manager_update_walk(dancer_id, is_walk)
	# 如果舞王刚刚入场，不让其移动，并不修改动画
	if is_start_enter:
		walking_status = WalkingStatus.end
	else:
		## 攻击方向
		scale = direction_scale
		ray_cast_2d.scale = scale
		label_hp.scale = scale
		animation_player.play("eat")
		
		anim_change = true


func end_attack():
	
	_curr_character = null
	
	is_attack = false
	is_walk = true
	
	dancer_manager.manager_update_walk(dancer_id, is_walk)
	#跟随跳舞
	allow_dance()
	

## 舞王管理器调用该方法控制walk
func manager_update_walk(curr_is_walk):
	is_walk = curr_is_walk
	
#endregion
	
#region 动画相关
## 血量状态为3时的动画相关参数变化,父类调用该方法的函数删除已删除碰撞器
func hp_status_3_anim_para():
	is_death = true
	## 僵尸若正在播放动画，则等待结束
	if animation_player.is_playing():
		await animation_player.animation_finished
	## 如果不是死亡动画结束发射的信号
	if not curr_anim_death:
		animation_player.play("death")
		anim_change = true

## 动画结束处判断是否死亡，循环动画不发射动画结束信号，在动画轨道调用该函数
func anim_judge_death():
	if is_death:
		curr_anim_death = true
		animation_player.play("death")
		anim_change = true

## 由于舞王动画未使用animationtree,完全重写该方法
func state_transition_judge_walking_status():
	if anim_change:
		anim_change = false
		_walking_start()
		
#endregion

#region 重写冰冻减速更新动画速度部分代码
func update_anim_speed_scale(animation_speed, is_norm=true):
	dancer_manager.update_anim_speed_scale(animation_speed, dancer_id, is_norm)
	

## 舞王管理器调用该方法控制速度
func manager_update_anim_speed(new_speed_scale):
	animation_player.speed_scale = new_speed_scale

## 僵尸删除area,即僵尸死亡
func _delete_area2d():
	super._delete_area2d()
	## 更新舞王管理器对应id僵尸速度和对应僵尸
	dancer_manager_change()

## 僵尸失误更新舞王管理器，并更新舞王管理器父节点
func dancer_manager_change():
	## 更新舞王管理器对应id僵尸速度和对应僵尸
	dancer_manager.manager_update_speed_is_norm(dancer_id, true)
	dancer_manager.zombie_dancers[dancer_id] = false
	## 更新舞王管理器的移动
	dancer_manager.manager_update_walk(dancer_id, true)
	
	## 如果是舞王僵尸，或者是当前持有dancer_manager的伴舞僵尸死亡
	if dancer_id == -1 or not dancer_manager.zombie_dancers[dancer_id]:
		dancer_manager.change_manager_parent()
	
#endregion

#僵尸被魅惑
func be_hypnotized():
	super.be_hypnotized()
	dancer_manager_change()
	
	var new_dancer_manager = DancerManagerScene.instantiate()
	add_child(new_dancer_manager)
	dancer_manager = new_dancer_manager
	
	dancer_manager.start_anim()
	dancer_manager._init_anim_speed(animation_origin_speed, self)
	dancer_manager.is_hypnotized = true
	
	direction_scale = Vector2(-1, 1)
	
	print("舞王或伴舞被魅惑")


#endregion

func call_end():
	is_start_enter = false

## 舞王管理器管理动画播放
func anim_play(name, curr_scale, start_time, speed):

	## 非攻击状态更新,非死亡状态,非舞王入场状态
	if not is_attack and not is_death and not is_start_enter and not is_bomb_death:
		_walking_end()
		## 最后一次举手需要举起，重新创建了新动画控制播放时间
		if name == "armraise_end":
			name = "armraise"
			
		## 如果是唤伴舞动画,入场标志已结束使用，这里重复使用一下
		if name == "point":
			is_start_enter = true
			
		## 开始时间为0时
		if start_time == 0:
			animation_player.play(name)
			animation_player.seek(0)
		else:
			animation_player.play_section(name, start_time)
		## 控制舞王方向
		scale = curr_scale * direction_scale

		ray_cast_2d.scale = scale
		label_hp.scale = scale
		
		anim_change = true
		
		return true
		
	return false
	
	
## 从特殊状态（舞王入场、攻击）修改跟随跳舞
func allow_dance():
	var anim_info = dancer_manager.get_current_animation_info()
	anim_play(anim_info['name'], anim_info['curr_scale'], anim_info['current_time'], anim_info['speed'])
	
	anim_change = true
	

### 使用舞王管理器召唤伴舞僵尸
func call_zombie_dancer():
	if not area2d_free:
		dancer_manager.call_zombie_dancer()
