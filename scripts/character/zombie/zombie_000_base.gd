extends Character000Base
class_name Zombie000Base

@onready var attack_component:AttackComponentBase= %AttackComponent
@onready var hp_stage_change_component: HpStageChangeComponent = %HpStageChangeComponent
@onready var charred_component: CharredComponent = %CharredComponent
@onready var move_component: MoveComponent = %MoveComponent
@onready var swim_box_component: SwimBoxComponent = %SwimBoxComponent
@onready var drop_item_component: DropItemComponent = %DropItemComponent

#region 僵尸类基础属性
@export var zombie_type:Global.ZombieType
## 僵尸基础属性参数，_ready初始化
@export_group("僵尸基础属性")
@export_subgroup("僵尸铁器")
## 僵尸铁器类型
@export var iron_type:Global.IronType = Global.IronType.Null
## 僵尸铁器节点
@export var iron_node:Node2D
@export_subgroup("僵尸初始化状态")
## 僵尸初始化状态（从1[is_norm] 开始，被攻击时是否能被攻击到的属性）
@export var init_be_attack_status :E_BeAttackStatusZombie = 1
## 僵尸出生波次
var curr_wave:=-1
## 僵尸当前状态
var curr_be_attack_status:E_BeAttackStatusZombie:
	set(value):
		curr_be_attack_status = value
		signal_status_change.emit(self, curr_be_attack_status)

## 当前僵尸所在行，陆地、水池
var curr_zombie_row_type:Global.ZombieRowType=Global.ZombieRowType.Land
## 水路两栖僵尸当前行为水路时body变化
@export var body_change_on_pool:ResourceBodyChange

## 是否可以触发倭瓜位置判定，默认都为否，可以跳跃的僵尸跳跃组件跳跃后修改为否
@export var is_trigger_squash_pos_judge := false

## 状态变化信号
signal signal_status_change(zombie:Zombie000Base, curr_be_attack_status:E_BeAttackStatusZombie)
## 僵尸掉血信号（只有僵尸使用）,参数为损失的血量值
signal signal_zombie_hp_loss(all_loss_hp:int, wave:int)

#endregion

#region 角色枚举
## 检测攻击时，根据状态判断是否可以攻击
enum E_BeAttackStatusZombie{
	IsNorm = 1,		## 正常
	IsJump = 2,		## 跳跃
	IsDownPool = 4,		## 水下
	IsSky = 8,			## 空中
	IsDownGround = 16,	## 地下
	IsJumpInPool = 32,	## 跳入泳池,该状态无法被高建国拦截
}

#endregion

#region 僵尸动画状态参数
@export_group("动画状态")
## 默认为移动状态,is_walk由多种状态控制
@export var is_walk := true
@export var is_attack := false:
	set(value):
		is_attack = value
		_judge_is_walk()
@export var is_swimming := false
## 父类通用
#var is_death := false

## 被炸死
var is_bomb_death := false:
	set(value):
		is_bomb_death = value
		_judge_is_walk()

## is_walk由is_attack 和 is_bomb_death控制
func _judge_is_walk():
	is_walk = not is_attack and not is_bomb_death

#endregion

## 修改初始化状态，在添加到场景树之前调用
func init_zombie(
	character_init_type:E_CharacterInitType, 	## 角色初始化类型（正常、展示）
	curr_zombie_row_type:Global.ZombieRowType,	## 僵尸所在行属性（水、陆地）
	lane:int = -1, 	## 僵尸行
	curr_wave:int = -1,		## 僵尸波次
	curr_pos:Vector2 = Vector2.ZERO,	## 僵尸局部位置
):
	self.character_init_type = character_init_type
	self.curr_zombie_row_type = curr_zombie_row_type
	self.lane = lane
	self.curr_wave = curr_wave
	self.position = curr_pos

	## 两栖类僵尸在水路时变化
	if Global.get_zombie_info(zombie_type, Global.ZombieInfoAttribute.ZombieRowType) == Global.ZombieRowType.Both:
		## 水路时body变化
		if curr_zombie_row_type == Global.ZombieRowType.Pool and body_change_on_pool:
			for sprite_path in body_change_on_pool.sprite_appear:
				var sprite = get_node(sprite_path)
				sprite.visible = true

			for sprite_path in body_change_on_pool.sprite_disappear:
				var sprite = get_node(sprite_path)
				sprite.visible = false


func _ready() -> void:
	super()
	curr_be_attack_status = init_be_attack_status
	hp_component.signal_zombie_hp_loss.connect(func(hp_loss:int): signal_zombie_hp_loss.emit(hp_loss, curr_wave))

## 初始化正常出战角色信号连接
func init_norm_signal_connect():
	super()
	## 僵尸普通攻击组件连接信号
	if attack_component is AttackComponentZombieNorm:
		## 血量组件发射死亡信号，使攻击力为0
		hp_component.signal_hp_component_death.connect(attack_component.change_attack_value.bind(0,AttackComponentZombieNorm.E_AttackValueFactor.Death))
		## 攻击组件
		attack_component.signal_change_is_attack.connect(move_component.update_move_factor.bind(move_component.E_MoveFactor.IsAttack))
		attack_component.signal_change_is_attack.connect(change_is_attack)
		## 攻击时受击组件
		attack_component.signal_change_is_attack.connect(be_attacked_box_component.change_area_attack_appear)

	## 血量状态变化组件
	hp_component.signal_hp_loss.connect(hp_stage_change_component.judge_body_change)
	## 防具血量状态变化组件
	hp_component.signal_hp_armor1_loss.connect(hp_stage_change_component.judge_body_change_armor.bind(true))
	hp_component.signal_hp_armor2_loss.connect(hp_stage_change_component.judge_body_change_armor.bind(false))

	## 当前动画结束时，移动组件改变移动状态
	anim_component.signal_animation_finished.connect(move_component._on_animation_finished)

	## 被魅惑信号
	signal_character_be_hypno.connect(be_attacked_box_component.owner_be_hypno)
	signal_character_be_hypno.connect(attack_component.owner_be_hypno)
	signal_character_be_hypno.connect(move_component._walking_start)

	## 游泳信号
	swim_box_component.signal_change_is_swimming.connect(change_is_swimming)

	## 铁器防具
	match iron_type:
		Global.IronType.IronArmor1:
			hp_component.signal_armor1_death.connect(func():iron_type=Global.IronType.Null)
		Global.IronType.IronArmor2:
			hp_component.signal_armor2_death.connect(func():iron_type=Global.IronType.Null)

	## 掉落战利品
	hp_component.signal_hp_component_death.connect(drop_item_component.drop_coin)
	hp_component.signal_hp_component_death.connect(drop_item_component.drop_garden_plant)

## 改变攻击状态攻击
func change_is_attack(value:bool):
	is_attack = value

## 改变游泳状态,切换动画时0.2秒过度时间停止移动
func change_is_swimming(value:bool):
	is_swimming = value
	move_component.update_move_factor(true, MoveComponent.E_MoveFactor.IsSwimingChange)
	await get_tree().create_timer(0.2).timeout
	move_component.update_move_factor(false, MoveComponent.E_MoveFactor.IsSwimingChange)
	shadow.visible = not value

#region 僵尸受伤、死亡、
## 角色死亡
func character_death():
	super()
	be_attacked_box_component.queue_free()
	swim_box_component._on_owner_is_death()
	#attack_component.queue_free()

## 僵尸死亡后逐渐透明，最后删除节点
func _fade_and_remove():
	var tween = create_tween()  # 自动创建并绑定Tween节点
	tween.tween_property(self, "modulate:a", 0.0, 1.0)  # 1秒内透明度降为0
	tween.tween_callback(queue_free)  # 动画完成后删除僵尸

## 死亡不消失(海草\TODO:小推车)
func character_death_not_disappear():
	hp_stage_change_component.is_no_change = true
	hp_component.Hp_loss_death()

## 死亡直接消失
func character_death_disappear():
	hp_stage_change_component.is_no_change = true
	hp_component.Hp_loss_death()
	queue_free()

## 被小推车碾压
## TODO: 修改为原版
func be_mowered_run():
	hp_component.Hp_loss_death()

## 角色在泳池中死亡,泳池死亡动画调用
func in_water_death_start():
	var tween = create_tween()
	# 仅移动y轴，在1.5秒内下移200像素
	tween.tween_property(body, "position:y", body.position.y + 80, 2)
	#swim_box_component.in_water_death_start()

## 被水草缠住,
func be_grap_in_pool():
	attack_component.disable_component(ComponentBase.E_IsEnableFactor.Death)
	anim_component.stop_anim()

## 被炸弹炸
## is_cherry_bomb:bool = false ：是否灰烬炸弹(非土豆雷)
func be_bomb(attack_value:int, is_cherry_bomb:bool = false):
	is_can_death_language = false
	hp_component.Hp_loss(attack_value, Global.AttackMode.Penetration, true, false)
	if is_death:
		## 在水中直接删除
		if curr_zombie_row_type == Global.ZombieRowType.Pool:
			queue_free()
		else:
			if is_cherry_bomb:
				anim_component.stop_anim()
				move_component.update_move_factor(true, MoveComponent.E_MoveFactor.IsBombDeath)
				charred_component.play_charred_anim()
			else:
				queue_free()
	#await get_tree().process_frame
	set_deferred("is_can_death_language", true)

## 被大嘴花吃
func be_chomper_eat(attack_value:int):
	is_can_death_language = false
	hp_component.Hp_loss(attack_value, Global.AttackMode.Penetration, true, false)
	if is_death:
		queue_free()
	#await get_tree().process_frame
	set_deferred("is_can_death_language", true)

## 被倭瓜压
func be_squash(attack_value:int=1800):
	is_can_death_language = false
	hp_component.Hp_loss(attack_value, Global.AttackMode.Penetration, true, false)
	if is_death:
		queue_free()
	#await get_tree().process_frame
	set_deferred("is_can_death_language", true)

#endregion
## 铁器被吸走
## 非一类防具和非二类防具需重写该函数
func be_remove_iron():
	match iron_type:
		Global.IronType.IronArmor1:
			hp_component.Hp_loss(hp_component.curr_hp_armor1, Global.AttackMode.Norm, true, false)
		Global.IronType.IronArmor2:
			hp_component.Hp_loss(hp_component.curr_hp_armor2, Global.AttackMode.Norm, true, false)

