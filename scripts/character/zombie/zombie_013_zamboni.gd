extends ZombieBase
class_name ZombieZamboni

@export var speed_car :float = 20
var curr_speed_car:float

@onready var ice_road: IceRoad = $IceRoad

@onready var zombie_zamboni_1: Sprite2D = $Body/Zombie_zamboni_1
@export var zamboni_damage_texture :Array[Texture2D]

@onready var death_bomb: ZamboniDeathBomb = $DeathBomb
@onready var bombs: Node2D = get_tree().current_scene.get_node("Bombs")
var is_caltrop := false
@onready var smoke: GPUParticles2D = $Body/Zombie_zamboni_1/Smoke


func _ready() -> void:
	super._ready()
	curr_speed_car = speed_car
	if not is_idle:
		init_ice_road()
		SoundManager.play_zombie_SFX(Global.ZombieType.ZombieZamboni, "zamboni")


## 被子弹减速（冰车不受子弹减速影响，重写该方法）
func be_decelerated_bullet(time_decelerate:float):
	pass


func _process(delta):
	if not is_idle:
		global_position.x -= curr_speed_car * delta * scale.x
		if ice_road:
			ice_road.expand_size(curr_speed_car * delta * scale.x)
		# 每帧检查射线是否碰到植物
		if ray_cast_2d.is_colliding():
			# 获取Area2D的父节点
			var collider = ray_cast_2d.get_collider()
			if collider:
				_curr_character = collider.get_parent()
				#TODO 冰车僵尸被魅惑是否有压扁僵尸
				if _curr_character as PlantBase:
					var plant:PlantBase = _curr_character as PlantBase
					
					plant.be_flattened_zomboni(self)


func _physics_process(delta: float) -> void:
	## 每帧扣血一次
	if is_bleed and curr_Hp >0:
		curr_Hp -= 1
		updata_hp_label()
		judge_status(false, false)

## 僵尸子类重写该方法，获取ground，部分僵尸修改body位置在panel节点下
func _get_some_node():
	body = $Body
	animation_tree = $AnimationTree
	# 获取状态机播放控制器
	playback = animation_tree.get("parameters/StateMachine/playback")


## 将冰冻放置于游戏背景上
func init_ice_road():
	var ori_global_position_ice_road = ice_road.global_position
	remove_child(ice_road)
	var main_game :MainGameManager = get_tree().current_scene
	main_game.background.add_child(ice_road)
	ice_road.global_position = ori_global_position_ice_road
	main_game.zombie_manager.ice_road_list[lane].append(ice_road)
	
	var hand_manager:HandManager = main_game.hand_manager
	ice_road.ice_road_init(lane, hand_manager.plant_cells_array[lane], main_game.zombie_manager)

	
## 潜水僵尸被减速时同时更新在水中的移动速度
func update_anim_speed_scale(animation_speed, is_norm=true):
	animation_tree.set("parameters/TimeScale/scale", animation_speed)
	curr_speed_car = animation_speed * speed_car

## 血量状态判断
func judge_status(no_drop:=false, trigger_be_attack_SFX:=true):
	## 若僵尸满血被小推车碾压，需要先判断掉手阶段血量，在判断掉头阶段血量
	if curr_Hp <= max_hp*2/3 and curr_hp_status < 2:
		curr_hp_status = 2
		zombie_zamboni_1.texture = zamboni_damage_texture[0]
		
	if curr_Hp <= max_hp/3 and curr_hp_status < 3:
		curr_hp_status = 3
		## 三分之一血后设置速度为原始的一半
		set_anim_speed(0.5, true)
		zombie_zamboni_1.texture = zamboni_damage_texture[1]
		smoke.emitting = true
		
	if curr_Hp <= 199 and curr_hp_status < 4:
		curr_hp_status = 4
		is_bleed = true		## 自动流血状态
		## 三分之一血后设置速度在为原始的一半
		set_anim_speed(0.5, true)
		var tween = create_tween()
		
		tween.tween_property(body, "position", body.position + Vector2(1, 1), 0.05).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
		tween.tween_property(body, "position", body.position, 0.05).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
		tween.set_loops()
		
	if curr_Hp <= 0 and curr_hp_status < 5:
		curr_hp_status = 5
		is_death = true
		
		set_anim_speed(0.5, true)
		_delete_area2d()	# 删除碰撞器
		
		ice_road.start_disappear_timer()
		
		## 如果血量小于0，将血量置为0
		if curr_Hp < 0:
			curr_Hp = 0
		## 如果血量大于0，但是已经死亡，将剩余血量发射受伤信号
		else:
			zombie_damaged.emit(get_zombie_all_hp(), curr_wave)
		
		## 让有一类防具和二类防具的僵尸防具血量都置为0，更新状态
		if armor_first_curr_hp > 0:
			armor_first_curr_hp = 0
			_judge_status_armor_1()
			
		if armor_second_curr_hp > 0:
			armor_second_curr_hp = 0
			_judge_status_armor_2()
		
		
		## 如果没有掉落物,即没有爆炸特效，#被樱桃炸弹炸死,删除death_bomb
		if no_drop:
			body.visible = false
			death_bomb.queue_free()
			## 避免没有删除僵尸，等待5秒后删除，该语句不应该出现
			await get_tree().create_timer(10).timeout
			print("避免没有删除僵尸，等待10秒后删除，该语句不应该出现")
			delete_zombie()
			
		else:
			zamboni_death_effect()
			
## 死亡特效
func zamboni_death_effect():
	body.visible = false
	# 死亡时动画
	child_node_change_parent(death_bomb, bombs)
	## 爆炸消失后，death_bomb调用僵尸死亡删除僵尸
	death_bomb.activate_it()
	SoundManager.play_zombie_SFX(Global.ZombieType.ZombieZamboni, "explosion")

	
func print_test():
	print("开始播放动画")

## 被地刺扎
func be_caltrop():
	_delete_area2d()
	zombie_damaged.emit(get_zombie_all_hp(), curr_wave)
	is_caltrop = true
	curr_speed_car = 0
	
## 僵尸直接死亡 （大嘴花、土豆雷、窝瓜）,冰车死亡有爆炸掉落
func disappear_death(all_hp:=false):
	if all_hp:
		Hp_loss(get_zombie_all_hp(), Global.AttackMode.Norm, false, false)
	else:
		Hp_loss(1800, Global.AttackMode.Norm, false, false)
		
	if is_death:
		delete_zombie()
