extends ZombieBobsledSingle
class_name ZombieBobsled

## 雪橇车节点
@export var bobsled_vehicle_sprite:Sprite2D
@export var bobsled_vehicle_hp_max:=300
@export var bobsled_vehicle_hp:int
@export var curr_bobsled_vehicle_hp_status = 0
## 雪橇车碰撞器
@onready var area_2d_2: Area2D = $Area2D2

## 雪橇车图片
@export var bobsled_vehicle_texture:Array[Texture2D]
@export var zombies_bobsled_single :Array[ZombieBobsledSingle]


## move_use_ground是否使用ground移动，is_swimming控制动画
@export var move_use_ground := true
## 雪橇车速度原始
@export var speed_bobsled :float = 50.0
## 速度当前
@export var curr_speed_bobsled :float
## 最小坐车x值，位置小于该x值下车
@export var min_ice_x :float = 10000
## 当前冰道列表
var curr_ice_list 

func _ready() -> void:
	super._ready()
	curr_speed_bobsled = speed_bobsled
	bobsled_vehicle_hp = bobsled_vehicle_hp_max
	if not is_idle:
		var zombie_manager :ZombieManager = get_tree().current_scene.zombie_manager
		## 获取当前冰道列表
		curr_ice_list = zombie_manager.ice_road_list[lane]
		for ice_road:IceRoad in curr_ice_list:
			ice_road.ice_road_disappear_signal.connect(ice_disappear)
			ice_road.ice_road_update_signal.connect(ice_update)
			if min_ice_x == 0:
				min_ice_x = ice_road.left_x
			elif min_ice_x > ice_road.left_x:
				min_ice_x = ice_road.left_x
				
		await get_tree().create_timer(4).timeout
		bobsled_jump()
		
## 当前道路有冰道消失时
func ice_disappear(ice_road:IceRoad):
	if curr_ice_list.is_empty():
		bobsled_end()
	else:
		var curr_min_ice_x :float= 10000
		for ice_road_i:IceRoad in curr_ice_list:
			if curr_min_ice_x > ice_road.left_x:
				curr_min_ice_x = ice_road.left_x
		min_ice_x = curr_min_ice_x
		
## 当前道路有冰道更新时
func ice_update(ice_road:IceRoad):
	for ice_road_i:IceRoad in curr_ice_list:
		if min_ice_x > ice_road.left_x:
			min_ice_x = ice_road.left_x
				
	
	
func updata_hp_label():
	super.updata_hp_label()
	if bobsled_vehicle_hp > 0:
		label_hp.get_node('Label').text = label_hp.get_node('Label').text + "+" + str(bobsled_vehicle_hp)
	

## 重写受伤函数
func Hp_loss(attack_value:int, bullet_mode : Global.AttackMode = Global.AttackMode.Norm, trigger_be_attack_SFX:=true, no_drop:= false):
	## 如果雪橇车还有血
	if bobsled_vehicle_hp > 0:
		var ori_bobsled_vehicle_hp = bobsled_vehicle_hp
		bobsled_vehicle_hp -= attack_value
		
		## 如果还有剩余攻击力
		if bobsled_vehicle_hp <= 0:
			attack_value = -bobsled_vehicle_hp
			super.Hp_loss(attack_value, bullet_mode, trigger_be_attack_SFX, no_drop)
			## 如果掉血完之后死亡,直接删除僵尸(车上所有僵尸)
			if is_death:
				delete_zombie()
			else:
				if not is_bobsled_end:
					## 解散雪橇车
					bobsled_end()
			
			zombie_damaged.emit(ori_bobsled_vehicle_hp, curr_wave)
			updata_hp_label()
			
		else:
			zombie_damaged.emit(attack_value, curr_wave)
		
		
		change_bobsled_vehicle_texture()
		
	else:
		super.Hp_loss(attack_value, bullet_mode, trigger_be_attack_SFX, no_drop)

	
func change_bobsled_vehicle_texture():
	
	# 雪橇车第一次血量小于0， 将小于0的血量返回，表示剩余攻击力
	if bobsled_vehicle_hp <= 0 and curr_bobsled_vehicle_hp_status < 4:
		curr_bobsled_vehicle_hp_status = 4
		bobsled_vehicle_sprite.texture = bobsled_vehicle_texture[3]
		bobsled_vehicle_sprite.visible = false
		area_2d_2.queue_free()
		
	# 第一次血量小于1/3
	elif bobsled_vehicle_hp <= bobsled_vehicle_hp_max / 3 and curr_bobsled_vehicle_hp_status < 3:
		curr_bobsled_vehicle_hp_status = 3
		bobsled_vehicle_sprite.texture = bobsled_vehicle_texture[2]
		
		return 0
	
	# 第一次血量小于2/3
	elif bobsled_vehicle_hp <= bobsled_vehicle_hp_max * 2/ 3 and curr_bobsled_vehicle_hp_status < 2:
		curr_bobsled_vehicle_hp_status = 2
		bobsled_vehicle_sprite.texture = bobsled_vehicle_texture[1]

		return 0
		
	else:
		return 0


## 僵尸被炸死	
func be_bomb_death():
	zombie_damaged.emit(get_zombie_all_hp(), curr_wave)
	area_2d_2.queue_free()
	
	if not is_bobsled_end:
		for zombie:ZombieBobsledSingle in zombies_bobsled_single:
			zombie.be_bomb_death()
			
	super.be_bomb_death()


## 获取当前僵尸所有血量（HP+防具）
func get_zombie_all_hp():
	return curr_Hp + armor_first_curr_hp + armor_second_curr_hp + bobsled_vehicle_hp



## 重写僵尸移动
func _zombie_walk(delta):
	# 检查状态变化,若动画改变，更新_walking_start()
	state_transition_judge_walking_status()

	## 检查是否移动,is_bomb_death不移动
	if is_walk and not is_bomb_death:
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
			position.x -= scale.x * curr_speed_bobsled * delta
			if global_position.x < min_ice_x:
				print(is_bomb_death)
				bobsled_end()

## 雪橇车结束
func bobsled_end():
	if not is_bobsled_end:
		bobsled_vehicle_hp = 0
		move_use_ground = true
		super.bobsled_end()
		bobsled_vehicle_sprite.visible = false
		area_2d_2.queue_free()
		var zombie_manager:ZombieManager = get_tree().current_scene.get_node("Manager/ZombieManager")
		for zombie:ZombieBobsledSingle in zombies_bobsled_single:
			call_deferred("change_zombie", zombie, zombie_manager)

func change_zombie(zombie:ZombieBobsledSingle, zombie_manager:ZombieManager):
	zombie.lane = lane

	var zombie_global_position = zombie.global_position
	remove_child(zombie)
	zombie_manager.zombies_row_node[lane].add_child(zombie)
	zombie_manager.zombies_all_list[lane].append(zombie)
	zombie.global_position = zombie_global_position

	zombie.bobsled_end()
	if not zombie.is_death:
		## 连接死亡和魅惑信号，增加僵尸总数
		zombie_manager.new_zombie_connect_signal(zombie)

## 开始跳车
func bobsled_jump():
	## 如果车还没死亡
	if not is_bobsled_end:
		is_jump = true
		move_use_ground = false
		for zombie:ZombieBobsledSingle in zombies_bobsled_single:
			zombie.be_call_jump()
			
## 修改车的位置，在最前面图层
func move_bobsled_vehicle_sprite():
	move_child(bobsled_vehicle_sprite, get_child_count() - 1)


func keep_idle():
	super.keep_idle()
	for z:ZombieBobsledSingle in zombies_bobsled_single:
		z.keep_idle()
