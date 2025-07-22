extends CharacterBase
class_name ZombieBase

#region 僵尸基础属性
@export_group("僵尸基础属性")
## 僵尸类型
@export var zombie_type : Global.ZombieType
## 僵尸攻击力每帧扣血
var frame_counter := 0
@export var damage_per_second := 100
var _curr_damage_per_second : int
var _curr_character :CharacterBase

## 僵尸所在行
@export var lane : int = -1
## 僵尸合法行，陆地、水、两者都可以
@export var zombie_row_type := ZombieRow.ZombieRowType.Both
var curr_zombie_row_type = ZombieRow.ZombieRowType.Land
## 僵尸所属波次
@export var curr_wave:int = -1
## 僵尸受击音效是否为铁器防具 一类防具
@export var be_bullet_SFX_is_shield_first := false
## 僵尸受击音效是否为铁器防具 二类防具
@export var be_bullet_SFX_is_shield_second := false

#endregion

#region 僵尸状态，用于动画改变
@export_group("僵尸状态")
@export_subgroup("管理僵尸动画")
@export var is_idle := false
@export var is_walk := true			## 默认为移动状态
@export var is_attack := false
@export var is_death := false

@export_subgroup("管理僵尸死亡")
## 僵尸是否删除碰撞器，表示僵尸是否死亡，用于传递僵尸被击杀信号
@export var area2d_free:bool = false

#endregion

#region 僵尸防具血量变化

@export_group("僵尸防具血量变化")
@export_subgroup("血量状态")
@export var curr_hp_status := 1			## 血量状态

@export var zombie_outerarm_upper: Sprite2D							## 上半胳膊
@export var zombie_outerarm_upper_sprite2d_textures : Texture2D		## 上半胳膊残血图片

@export var zombie_status_2_fade: Array[Sprite2D]					## 僵尸血量状态2时隐藏精灵图（下半胳膊和手）
@export var hand_drop: Node2D		## 僵尸掉落的手

@export var zombie_status_3_fade: Array[Sprite2D]					## 僵尸血量状态3时隐藏精灵图（头部）
@export var head_drop: Node2D		## 僵尸掉落的头
@export var is_bleed :=false ## 自动流血

@export_subgroup("一类防具状态")
@export var curr_armor_1_hp_status := 1

@export var armor_first_max_hp := 0
@export var armor_first_curr_hp : int

@export var armor_1_sprite2d : Sprite2D
@export var armor_1_sprite2d_textures : Array[Texture2D]

@export var arm_1_drop: Node2D
## 一类防具受击音效(僵尸本体没有受击音效，本体被击中音效为子弹音效)
@export var arm_1_SFX: SoundManagerClass.TypeZombieBeAttackSFX


@export_subgroup("二类防具状态")
@export var curr_armor_2_hp_status := 1

@export var armor_second_max_hp := 0
@export var armor_second_curr_hp : int

@export var armor_2_sprite2d : Sprite2D
@export var armor_2_sprite2d_textures : Array[Texture2D]

@export var arm_2_drop: Node2D
## 二类防具受击音效
@export var arm_2_SFX: SoundManagerClass.TypeZombieBeAttackSFX

#endregion

#region 僵尸移动相关
@export_group("移动相关")
@onready var area2d : Area2D = $Area2D
var _ground : Sprite2D
var _previous_ground_global_x:float
enum  WalkingStatus {start, start2, walking, end}
@export var walking_status := WalkingStatus.start
## 动画控制器
var playback: AnimationNodeStateMachinePlayback

var prev_state:StringName
var is_transitioning: bool = false
#endregion

@export_group("其他")
## 僵尸攻击射线
@onready var ray_cast_2d: RayCast2D = $RayCast2D

#region 被爆炸炸死相关
@onready var zombie_charred: Node2D = $ZombieCharred
@onready var anim_lib: AnimationPlayer = $ZombieCharred/AnimLib
@export var is_bomb_death:bool = false	## 被炸死标记，控制僵尸不在移动

#endregion

## 僵尸被攻击信号，传递给ZombieManager,除了被魅惑，其余受伤害都从Hp_loss发射信号
signal zombie_damaged
## 僵尸被击杀信号，传递给ZombieManager
signal zombie_dead
## 僵尸被魅惑信号，传递给ZombieManager
signal zombie_hypno


#region 被魅惑相关
@export_group("被魅惑相关")
@export var is_hypnotized: bool = false
## 被魅惑颜色
var be_hypnotized_color := Color(1, 1, 1)
var be_hypnotized_color_res := Color(1, 0.5, 1)

#endregion


#region 游泳相关
@export_group("游泳相关")
@export var is_swimming := false
##游泳开始时僵尸需要出现的精灵图
@export var swim_zombie_appear_start : Array[Sprite2D]
##游泳消失的精灵图
@export var swimming_fade : Array[Sprite2D]
##游泳出现的精灵图
@export var swimming_appear : Array[Sprite2D]

#endregion


func _ready() -> void:
	super._ready()
	walking_status = WalkingStatus.start
	#_previous_ground_global_x = _ground.position.x
	
	armor_first_curr_hp = armor_first_max_hp
	armor_second_curr_hp = armor_second_max_hp
	
	_curr_damage_per_second = damage_per_second
	
	updata_hp_label()
	

		
## 僵尸子类重写该方法，获取ground，部分僵尸修改body位置在panel节点下
func _get_some_node():
	body = $Body
	_ground = $Body/_ground
	animation_tree = $AnimationTree
	shadow = $Body/shadow
	
	# 获取状态机播放控制器
	playback = animation_tree.get("parameters/StateMachine/playback")

func updata_hp_label():
	label_hp.get_node('Label').text = str(curr_Hp)
	if armor_first_curr_hp > 0:
		label_hp.get_node('Label').text = label_hp.get_node('Label').text + "+" + str(armor_first_curr_hp)

	if armor_second_curr_hp > 0:
		label_hp.get_node('Label').text = label_hp.get_node('Label').text + "+" + str(armor_second_curr_hp)
	
	if Global.display_zombie_HP_label:
		label_hp.visible = true
	else:
		label_hp.visible = false
		
	if is_idle:
		label_hp.visible = false


func _process(delta):
	_zombie_walk(delta)
	# 每帧检查射线是否碰到植物
	if ray_cast_2d.is_colliding():
		# 获取Area2D的父节点
		var collider = ray_cast_2d.get_collider()
		if collider:
			_curr_character = collider.get_parent()

		if not is_attack:
			start_attack()
		
	else:
		if is_attack:
			end_attack()


func _zombie_walk(delta):
	# 检查状态变化,若动画改变，更新_walking_start()
	state_transition_judge_walking_status()

	## 检查是否移动,is_bomb_death不移动
	if is_walk and not is_bomb_death:
		
		if walking_status == WalkingStatus.end:
			_previous_ground_global_x = _ground.global_position.x
		elif walking_status == WalkingStatus.start:
			## 等待1帧，避免僵尸闪现
			await get_tree().process_frame
			walking_status = WalkingStatus.walking
			_previous_ground_global_x = _ground.global_position.x
		else:
			_walk()

			
func start_attack():

	is_walk = false
	is_attack = true
	
func end_attack():
	_curr_character = null
	is_attack = false
	is_walk = true
	

func _physics_process(delta: float) -> void:
	
	## 每帧扣血一次
	if is_bleed and curr_Hp >0:
		curr_Hp -= 1
		updata_hp_label()
	
	## 如果正在攻击
	if judge_can_attack():
		## 每4帧扣血一次
		frame_counter += 1
		
		if not is_iced:
			# 每三帧植物掉血一次，被减速每6帧植物掉血一次 
			if is_decelerated:
				if frame_counter % 6 == 0:
					_curr_character.be_eated(_curr_damage_per_second * delta * 3, self)
				
			else:
				if frame_counter % 3 == 0:
					_curr_character.be_eated(_curr_damage_per_second * delta * 3, self)
			
		# 防止过大，每 10000 帧归零（大概每 167 秒）
		if frame_counter >= 10000:
			frame_counter = 0
	

## 判断是否攻击，舞王重写
func judge_can_attack():
	return _curr_character and is_attack and not area2d_free

## 判断动画是否改变,修改walking_status，由于从攻击动画到移动动画有渐变，需要先等待时间在更新_walking_start
## 子类可重写await的条件
func state_transition_judge_walking_status():
	 #检查从"eat"到"walk"的转换
	var current_state = playback.get_current_node()
	if current_state != prev_state:
		_walking_start()
		prev_state = current_state


## 获取当前僵尸所有血量（HP+防具）
func get_zombie_all_hp():
	return curr_Hp + armor_first_curr_hp + armor_second_curr_hp


#region 僵尸移动相关
func _walking_end():
	walking_status = WalkingStatus.end
	_previous_ground_global_x = _ground.global_position.x


func _walking_start():
	walking_status = WalkingStatus.start
	_previous_ground_global_x = _ground.global_position.x


func _walk():
	# 计算ground的全局坐标变化量
	var ground_global_offset = _ground.global_position.x - _previous_ground_global_x
	# 反向调整zombie的position.x以抵消ground的移动
	self.position.x -= ground_global_offset
	# 更新记录值
	_previous_ground_global_x = _ground.global_position.x
#endregion

#region 僵尸被攻击
## 被锤子
func be_attacked_hammer(attack_value:int):
	## 掉血，发光,直接调用父类方法
	super.be_attacked_bullet(attack_value, Global.AttackMode.Hammer)
	return is_death

#region 僵尸血量防具改变
## 有二类防具的情况下判断，掉血前二类防具血量大于0
func _judge_status_armor_2():
	# 二类防具第一次血量小于0， 将小于0的血量返回，表示剩余攻击力
	if armor_second_curr_hp <= 0 and curr_armor_2_hp_status < 4:
		curr_armor_2_hp_status = 4
		armor_2_sprite2d.visible = false
		
		## 二类防具音效改变
		be_bullet_SFX_is_shield_second = false
		arm2_drop()
		var res_attack = -armor_second_curr_hp
		armor_second_curr_hp = 0
		return res_attack
		
	# 第一次血量小于1/3
	elif armor_second_curr_hp <= armor_second_max_hp / 3 and curr_armor_2_hp_status < 3:
		curr_armor_2_hp_status = 3
		armor_2_sprite2d.texture = armor_2_sprite2d_textures[1]
		
		return 0
	
	# 第一次血量小于2/3
	elif armor_second_curr_hp <= armor_second_max_hp * 2/ 3 and curr_armor_2_hp_status < 2:
		curr_armor_2_hp_status = 2
		armor_2_sprite2d.texture = armor_2_sprite2d_textures[0]

		return 0
		
	else:
		return 0

## 二类防具掉落
func arm2_drop():
	## 如果是水路僵尸并且没有入水
	if curr_zombie_row_type == ZombieRow.ZombieRowType.Pool and not is_swimming:
		arm_2_drop.acitvate_it(50)
	else:
		arm_2_drop.acitvate_it()


## 有一类防具的情况下判断，掉血前一类防具血量大于0
func _judge_status_armor_1():
	# 一类防具第一次血量小于0， 将小于0的血量返回，表示剩余攻击力
	if armor_first_curr_hp <= 0 and curr_armor_1_hp_status < 4:
		curr_armor_1_hp_status = 4
		armor_1_sprite2d.visible = false
		
		## 一类防具音效改变
		be_bullet_SFX_is_shield_first = false
		arm1_drop()
		var res_attack = -armor_first_curr_hp
		armor_first_curr_hp = 0
		return res_attack
		
	# 第一次血量小于1/3
	elif armor_first_curr_hp <= armor_first_max_hp / 3 and curr_armor_1_hp_status < 3:
		curr_armor_1_hp_status = 3
		armor_1_sprite2d.texture = armor_1_sprite2d_textures[1]
		
		return 0
	
	# 第一次血量小于2/3
	elif armor_first_curr_hp <= armor_first_max_hp * 2/ 3 and curr_armor_1_hp_status < 2:
		curr_armor_1_hp_status = 2
		armor_1_sprite2d.texture = armor_1_sprite2d_textures[0]

		return 0
		
	else:
		return 0

## 一类防具掉落
func arm1_drop():
	## 如果是水路僵尸并且没有入水
	if curr_zombie_row_type == ZombieRow.ZombieRowType.Pool and not is_swimming:
		arm_1_drop.acitvate_it(50)
	else:
		arm_1_drop.acitvate_it()

#endregion

#region 僵尸血量改变
## 僵尸被攻击时掉血（包括防具变化）
## @param attack_value:int 伤害
## @param bullet_mode : Global.AttackMode = Global.AttackMode.Norm 伤害类型
## @param trigger_be_attack_SFX:=true,  是否有受击音效
## @param no_drop:= false 伤害是否有掉落（防具、手、头）
func Hp_loss(attack_value:int, bullet_mode : Global.AttackMode = Global.AttackMode.Norm, trigger_be_attack_SFX:=true, no_drop:= false):
	var ori_hp = get_zombie_all_hp()
	var ori_zombie_hp = curr_Hp
	var ori_arm_1_hp = armor_first_curr_hp
	var ori_arm_2_hp = armor_second_curr_hp
	
	match bullet_mode:
		## 普通子弹
		Global.AttackMode.Norm:
			# 如果有二类防具，先对二类防具掉血，若二类防具血量<0, 修改
			if armor_second_curr_hp > 0:
					
				armor_second_curr_hp -= attack_value
				attack_value = _judge_status_armor_2()
			
			# 如果有一类防具
			if armor_first_curr_hp > 0 and attack_value > 0:
				
				armor_first_curr_hp -= attack_value
				attack_value = _judge_status_armor_1()
			
			# 血量>0
			if curr_Hp > 0 and attack_value > 0:
				curr_Hp -= attack_value
				judge_status(no_drop)

		## 穿透子弹,爆炸
		Global.AttackMode.Penetration:
			
			# 如果有二类防具，先对二类防具掉血，若二类防具血量<0, 修改
			if armor_second_curr_hp > 0:
				
				armor_second_curr_hp -= attack_value
				_judge_status_armor_2()
				
			# 如果有一类防具
			if armor_first_curr_hp > 0 and attack_value > 0:
				armor_first_curr_hp -= attack_value
				attack_value = _judge_status_armor_1()
			
			# 血量>0
			if curr_Hp > 0 and attack_value > 0:
				curr_Hp -= attack_value
				judge_status(no_drop)
		
		## 真实伤害子弹
		Global.AttackMode.Real:
				
			# 如果有一类防具
			if armor_first_curr_hp > 0 and attack_value > 0:
				armor_first_curr_hp -= attack_value
				attack_value = _judge_status_armor_1()
				
				
			# 血量>0
			if curr_Hp > 0 and attack_value > 0:
				curr_Hp -= attack_value
				judge_status()
		
		## 保龄球子弹
		Global.AttackMode.BowlingFront:
			# 如果是正面
			# 如果有二类防具，先对二类防具掉血
			if armor_second_curr_hp > 0:
				# 如果为正面,无溢出伤害对二类防具造成400血量
				armor_second_curr_hp -= 400
				attack_value = _judge_status_armor_2()
				attack_value = 0

			# 如果有一类防具
			if armor_first_curr_hp > 0 and attack_value > 0:
				## 对一类防具造成无溢出伤害800
				armor_first_curr_hp -= 800
				attack_value = _judge_status_armor_1()
				attack_value = 0
				
			# 血量>0
			if curr_Hp > 0 and attack_value > 0:
				#若有溢出伤害或没有防具 对僵尸本体造成1800伤害
				curr_Hp -= 1800
				judge_status()
				
		## 保龄球侧面子弹
		Global.AttackMode.BowlingSide:
			
			#如果是正面
			# 如果有二类防具，先对二类防具掉血，若二类防具血量<0, 修改
			if armor_second_curr_hp > 0:
				
				#如果为侧面,二类防具造成1800血量， 溢出伤害1800
				armor_second_curr_hp -= 1800
				attack_value = _judge_status_armor_2()
				attack_value = 1800

			# 如果有一类防具
			if armor_first_curr_hp > 0 and attack_value > 0:
				
				## 对一类防具造成无溢出伤害800
				armor_first_curr_hp -= 800
				attack_value = _judge_status_armor_1()
				attack_value = 0

			# 血量>0
			if curr_Hp > 0 and attack_value > 0:
				#若有溢出伤害或没有防具 对僵尸本体造成1800伤害
				curr_Hp -= 1800
				judge_status()
		
		## 锤子		
		Global.AttackMode.Hammer:
			# 如果有二类防具，无视二类防具,
			if armor_second_curr_hp > 0:
				pass
			# 如果有一类防具
			if armor_first_curr_hp > 0 and attack_value > 0:
				## 对一类防具造成无溢出伤害800
				armor_first_curr_hp -= 900
				attack_value = _judge_status_armor_1()
				attack_value = 0
				
			# 血量>0 本体代码杀
			if curr_Hp > 0 and attack_value > 0:
				#若有溢出伤害或没有防具 对僵尸本体造成伤害
				is_death = true
				_delete_area2d()	# 删除碰撞器,发射死亡信号
				## 如果被锤子击杀，直接删除该僵尸
				queue_free()
	
	## 如果有受击音效，根据掉血的防具触发音效，
	## 我写的是僵尸本体没有受击音效，本体受击音效为子弹破裂音效
	#print("有受击音效")
	if trigger_be_attack_SFX: 
		if ori_arm_2_hp > armor_second_curr_hp and arm_2_SFX != SoundManagerClass.TypeZombieBeAttackSFX.Null:
			SoundManager.play_be_attack_SFX(arm_2_SFX)
		elif ori_arm_1_hp > armor_first_curr_hp and arm_1_SFX != SoundManagerClass.TypeZombieBeAttackSFX.Null:
			SoundManager.play_be_attack_SFX(arm_1_SFX)
			
	updata_hp_label()
	
	var res_hp = get_zombie_all_hp()
	var loss_hp = ori_hp - res_hp
	zombie_damaged.emit(loss_hp, curr_wave)


## 血量状态判断
func judge_status(no_drop:=false, trigger_be_attack_SFX:=true):
	## 若僵尸满血被小推车碾压，需要先判断掉手阶段血量，在判断掉头阶段血量
	if curr_Hp <= max_hp*2/3 and curr_hp_status < 2:
		curr_hp_status = 2
		_hp_2_stage()
		
	if curr_Hp <= max_hp/3 - 1 and curr_hp_status < 3:
		curr_hp_status = 3
		is_bleed = true
		hp_status_3_anim_para()
		_delete_area2d()	# 删除碰撞器
		
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
			
		
		_hp_3_stage(trigger_be_attack_SFX)
		## 如果没有掉落物,删除还未掉落的body
		if no_drop:
			if hand_drop:
				hand_drop.queue_free()
			if head_drop:
				head_drop.queue_free()
			if arm_1_drop:
				arm_1_drop.queue_free()
			if arm_2_drop:
				arm_2_drop.queue_free()
		
		
## 血量状态为3时的动画相关参数变化
func hp_status_3_anim_para():
	is_death = true

## 第一次血量2阶段变化 掉手状态
func _hp_2_stage():
	_hand_fade()

# 下半胳膊消失
func _hand_fade():
	## 隐藏下半胳膊
	for arm_hand_part in zombie_status_2_fade:
		arm_hand_part.visible = false
	## 如果有掉落手臂
	if hand_drop:
		## 如果是水路僵尸并且没有入水
		if curr_zombie_row_type == ZombieRow.ZombieRowType.Pool and not is_swimming:
			hand_drop.acitvate_it(40)
		else:
			hand_drop.acitvate_it()
	
	## 修改上半胳膊图片（残血图片）
	zombie_outerarm_upper.texture = zombie_outerarm_upper_sprite2d_textures
	

## 第一次血量3阶段变化 掉头状态
func _hp_3_stage(trigger_be_attack_SFX:=true):
	_head_fade(trigger_be_attack_SFX)
	
# 头消失，掉头音效
func _head_fade( trigger_be_attack_SFX:=true):
	if trigger_be_attack_SFX == false:
		SoundManager.play_zombie_SFX(Global.ZombieType.ZombieNorm, "Shoop")
		
	for head_part in zombie_status_3_fade:
		head_part.visible = false
		
	## 如果是水路僵尸并且没有入水
	if curr_zombie_row_type == ZombieRow.ZombieRowType.Pool and not is_swimming:
		head_drop.acitvate_it(40)
	else:
		head_drop.acitvate_it()
#endregion
#endregion

## 僵尸啃咬一次，动画中调用,攻击音效
func _attack_once():
	if not area2d_free:
		SoundManager.play_zombie_SFX(Global.ZombieType.ZombieNorm, "Chomp")
		if _curr_character:
			_curr_character.be_eated_once(self)

#region 僵尸特殊状态:魅惑
#僵尸被魅惑
func be_hypnotized():
	be_hypnotized_base()
	be_hypnotized_signal()

## 被魅惑后的基础改变
func be_hypnotized_base():
	
	is_hypnotized = true
	# 重置碰撞器所在层数
	area2d.collision_layer = 32		#第6层
	
	# 重置检测射线的碰撞层
	ray_cast_2d.collision_mask = 0
	# 添加第4层和第5层（注意层索引从0开始，所以第3层是索引2，第5层是索引4）
	ray_cast_2d.collision_mask |= 1 << 2  # 第3层 僵尸层
	ray_cast_2d.collision_mask |= 1 << 4  # 第5层 撑杆跳跳跃层
	
	flip_zombie()
	
	# 更新僵尸颜色
	be_hypnotized_color = be_hypnotized_color_res
	_update_modulate()
	## 被魅惑后重新移动
	walking_status = WalkingStatus.start
	
	
## 被魅惑后信号更新
func be_hypnotized_signal():
	## 发送僵尸被攻击和死亡信号
	var zombie_all_hp = get_zombie_all_hp()
	zombie_damaged.emit(zombie_all_hp, curr_wave)
	zombie_dead.emit(self)
	## 断开信号连接
	var connections_damaged = zombie_damaged.get_connections()
	for conn in connections_damaged:
		zombie_damaged.disconnect(conn["callable"])
		
	var connections_dead = zombie_dead.get_connections()
	for conn in connections_dead:
		zombie_dead.disconnect(conn["callable"])
	
	zombie_hypno.emit(self)
	
	var connections_hypno = zombie_hypno.get_connections()
	for conn in connections_hypno:
		zombie_hypno.disconnect(conn["callable"])
	


# 重写父类颜色变化
func _update_modulate():
	var final_color = base_color * _hit_color * debuff_color * be_hypnotized_color
	body.modulate = final_color

	
# 直接设置scale
func flip_zombie():
	# 进行水平翻转
	scale = scale * Vector2(-1, 1)
	
	label_hp.scale = scale

#endregion


#region 僵尸死亡相关
# 删除僵尸
func delete_zombie():
	self.queue_free()


## 被小推车碾压
func be_mowered_run():
	# 减速当前所有血量
	Hp_loss(get_zombie_all_hp(), Global.AttackMode.Norm, false)


## 被水池小推车吃
func be_pool_mowered_run():
	Hp_loss(get_zombie_all_hp(), Global.AttackMode.Norm, false, true)
	delete_zombie()


## 被大保龄球碾压
func be_big_bowling_run():
	# 减速当前所有血量
	Hp_loss(get_zombie_all_hp(), Global.AttackMode.Norm, false)


## 被水草缠住,这里先删除其碰撞器，下水后调用disappear_death(all_hp=true)发射掉血信号
func be_grap_in_pool():
	## 设置其死亡，避免僵尸离开泳池时往上移动
	is_death = true
	## 设置其被炸死，控制其不移动(好像用不到)
	is_bomb_death = true
	animation_tree.active = false
	_delete_area2d()


## 僵尸删除area,即僵尸死亡
func _delete_area2d():
	if not area2d_free:
		area2d_free = true
		_curr_damage_per_second = 0
		
		zombie_dead.emit(self)
		area2d.queue_free()
	
	
## 僵尸被炸死	
func be_bomb_death():
	## 爆炸伤害为穿透伤害，对二类防具造成伤害同时对一类防具（本体）造成伤害
	Hp_loss(1800, Global.AttackMode.Penetration, false, true)
	if is_death:
		### 清空血量
		body.visible = false
		is_bomb_death = true
		if animation_tree:
			animation_tree.active = false
		
		## 如果僵尸在水里
		if is_swimming:
			delete_zombie()
		else:
			zombie_charred.visible = true
			# 播放僵尸灰烬动画
			anim_lib.play("ALL_ANIMS")
			await anim_lib.animation_finished
			delete_zombie()

## 僵尸直接死亡 （大嘴花、土豆雷、窝瓜）
func disappear_death(all_hp:=false):
	if all_hp:
		Hp_loss(get_zombie_all_hp(), Global.AttackMode.Norm, false, true)
	else:
		Hp_loss(1800, Global.AttackMode.Norm, false, true)
		
	if is_death:
		delete_zombie()


## 僵尸死亡后逐渐透明，最后删除节点
func _fade_and_remove():
	var tween = create_tween()  # 自动创建并绑定Tween节点
	tween.tween_property(self, "modulate:a", 0.0, 1.0)  # 1秒内透明度降为0
	tween.tween_callback(delete_zombie)  # 动画完成后删除僵尸

#endregion


#region 水池游泳相关
func in_water_death_start():
	
	var tween = create_tween()
	# 仅移动y轴，在1.5秒内下移200像素
	tween.tween_property(body, "position:y", body.position.y + 80, 2)
	

func start_swim():
	
	# 水花
	var splash = Global.splash_pool_scenes.instantiate()
	add_child(splash)
	
	for sprite in swimming_fade:
		sprite.visible = false
	for sprite in swimming_appear:
		sprite.visible = true
		
	var tween = create_tween()
	# 仅移动y轴，在1.5秒内下移200像素
	tween.tween_property(body, "position:y", body.position.y + 30, 0.5)
	await tween.finished
	is_swimming = true
	
	
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
		
	is_swimming = false
	
	var tween = create_tween()
	# 仅移动y轴，在1.5秒内下移200像素
	tween.tween_property(body, "position:y", body.position.y - 30, 0.5)
	await tween.finished
	
## 碰撞到泳池
func _on_area_2d_area_entered(area: Area2D) -> void:
	start_swim()


func _on_area_2d_area_exited(area: Area2D) -> void:
	end_swim()

#endregion

#region idle展示状态(图鉴，开局展示)
func keep_idle():
	is_idle = true
	# 避免僵尸移动
	is_walk = false
	walking_status = WalkingStatus.end

	label_hp.visible = false
	## 删除展示僵尸碰撞箱
	area2d.queue_free()

#endregion
