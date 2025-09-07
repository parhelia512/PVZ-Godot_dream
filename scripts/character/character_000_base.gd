extends Node2D
class_name Character000Base

#region 子节点
@onready var body: BodyCharacter = %Body
## 角色必备组件(受击盒子组件、血量组件)
@onready var be_attacked_box_component: BeAttackedBoxComponent = %BeAttackedBoxComponent
@onready var hp_component: HpComponent = %HpComponent
@onready var anim_component: AnimComponentBase = %AnimComponent

## 冰冻减速和冰冻计时器
@onready var ice_decelerate_timer: Timer = $IceDecelerateTimer
@onready var ice_freeze_timer: Timer = $IceFreezeTimer
@onready var shadow: Sprite2D = %Shadow

#endregion

#region 基础属性

@export_group("角色方向")
## 角色实际方向改变时,body方向为角色实际方向基础的body方向
## 角色实际方向(1为默认方向,-1为反方向)被魅惑时改变方向
@export var direction_x_root := 1
## 不改变方向的节点(睡眠组件\血条显示),当角色实际方向改变时,将该组件方向修改回来
@export var node_no_change_direction:Array[Node2D]
## body方向(1为默认方向,-1为反方向)[舞王\花园使用]
@export var direction_x_body := 1
## 跟随body方向的节点(body\影子\僵尸身体掉落节点\灰烬)
@export var node_follow_body_direction:Array[Node2D]

@export_group("角色速度")
## 角色速度随机范围
@export var random_speed_range :Vector2 = Vector2(0.9, 1.1)
## 角色速度影响的组件(攻击)
@export var speech_influence_components:Array[ComponentBase]
var lane:int = -1
## 速度改变量
var influence_speed_factors :Dictionary[E_Influence_Speed_Factor, float]= {
}
enum E_Influence_Speed_Factor{
	InitRandomSpeed,
	IceDecelerateSpeed,
	IceFreezeSpeed,
	HammerZombieSpeed,	## 锤僵尸模式修改速度
	ZamboniHp,		## 冰车僵尸血量变化时
}
var is_hypno:bool = false
## 冰冻结束后减速时间（每次被冰冻时赋值）
var time_ice_end_decelerate := 5.0
## 冰冻特效
var ice_effect:IceEffect

## 是否可以触发亡语(爆炸\大嘴花不可以触发)
var is_can_death_language:=true

## 速度改变信号 speed_factor_product: 速度系数乘积
signal signal_update_speed(speed_factor_product:float)

@export_group("动画状态")
@export var is_death:=false
@export var is_idle := true
## 是否为展示\花园状态
@export var is_show := false

## 角色死亡信号
signal signal_character_death()
## 角色被魅惑信号
signal signal_character_be_hypno()
## 角色方向更新信号，被魅惑时发出，血条、睡觉显示方向修改
signal signal_direction_x_root_update(direction_x:int)
## body方向更新信号
signal signal_direction_x_body_update(direction_x:int)
#region 更新角色方向
## 更新角色本体方向
func update_direction_x_root(direction_x:int):
	direction_x_root = direction_x
	scale.x = direction_x
	signal_direction_x_root_update.emit(direction_x_root)

## 更新角色body方向
func update_direction_x_body(direction_x:int):
	direction_x_body = direction_x
	signal_direction_x_body_update.emit(direction_x_body)
#endregion

#region 展示show角色相关
@export_group("初始化类型相关")
enum E_CharacterInitType{
	IsNorm,		## 普通出战
	IsShow,		## 展示状态（关卡前展示、图鉴）
	IsGarden,	## 花园状态
}

## 角色初始化类型
@export var character_init_type :E_CharacterInitType = E_CharacterInitType.IsNorm

#endregion

#endregion
func _ready() -> void:
	match character_init_type:
		E_CharacterInitType.IsNorm:
			init_norm()
		E_CharacterInitType.IsShow:
			init_show()
		E_CharacterInitType.IsGarden:
			init_garden()

## 初始化正常出战角色信号连接
func init_norm_signal_connect():
	## 角色根改变方向（修改为同样的值,方向不变）
	for node2d:Node2D in node_no_change_direction:
		signal_direction_x_root_update.connect(func(dir_x:int): node2d.scale.x = dir_x)

	## 角色body改变方向（修改为同样的值,保持和body方向一致）
	for node2d:Node2D in node_follow_body_direction:
		signal_direction_x_body_update.connect(func(dir_x:int): node2d.scale.x = dir_x)

	## 速度修改信号连接动画速度
	signal_update_speed.connect(anim_component.update_anim_speed)

	## 血量组件发射死亡信号
	hp_component.signal_hp_component_death.connect(character_death)
	hp_component.signal_hp_component_death.connect(death_language)

	## 被魅惑
	signal_character_be_hypno.connect(body.owner_be_hypno)

	for component :ComponentBase in speech_influence_components:
		signal_update_speed.connect(component.owner_update_speed)

## 初始化正常出战角色
func init_norm():
	init_norm_signal_connect()
	is_show = false
	is_idle = false
	call_deferred("init_random_speed")

## 初始化展示角色
func init_show():
	is_show = true
	be_attacked_box_component.call_deferred("queue_free")

## 初始化花园角色
func init_garden():
	is_show = true
	be_attacked_box_component.call_deferred("queue_free")

## 随机初始化角色速度
func init_random_speed():
	## 初始化角色速度
	update_speed_factor(randf_range(random_speed_range.x, random_speed_range.y), E_Influence_Speed_Factor.InitRandomSpeed)

## 修改速度，发射信号
func update_speed_factor(value: float, influent_speed_factor:E_Influence_Speed_Factor) -> void:
	influence_speed_factors[influent_speed_factor] = value
	signal_update_speed.emit(GlobalUtils.get_dic_product(influence_speed_factors))

#region 死亡、受击相关
## 亡语
func death_language():
	pass

## 角色死亡,子类继承重写
func character_death():
	is_death = true
	signal_character_death.emit()

## 被攻击至死亡(大保龄球)
func be_attack_to_death(trigger_be_attack_SFX:=true):
	hp_component.Hp_loss(hp_component.get_all_hp(), Global.AttackMode.Norm, false,trigger_be_attack_SFX)

## 死亡不消失(海草\被碾压\TODO:小推车)
func character_death_not_disappear():
	pass

## 死亡直接消失
func character_death_disappear():
	pass
	hp_component.Hp_loss_death()
	queue_free()

## 被子弹攻击
func be_attacked_bullet(attack_value:int, bullet_mode:Global.AttackMode=Global.AttackMode.Norm, is_no_drop:bool=false, trigger_be_attack_SFX:=true):
	hp_component.Hp_loss(attack_value, bullet_mode, is_no_drop, trigger_be_attack_SFX)
	body.body_light()

## 被锤子攻击(伤害值不生效)
func be_attacked_hammer(attack_value:int):
	hp_component.Hp_loss(attack_value, Global.AttackMode.Hammer, false, true)
	body.body_light()
	return is_death


## 被僵尸啃食
## attack_value:伤害
## attack_zombie:攻击的僵尸
func be_zombie_eat(attack_value:int, attack_zombie:Zombie000Base):
	hp_component.Hp_loss(attack_value, Global.AttackMode.Penetration, false, false)

## 被僵尸啃食一次发光
func be_zombie_eat_once(attack_zombie:Zombie000Base):
	body.body_light()

## 被魅惑
func be_hypno():
	is_hypno = true
	signal_character_be_hypno.emit()
	update_direction_x_root(-direction_x_root)

	#be_attacked_box_component.disable_component(ComponentBase.E_IsEnableFactor.Hypno)
	#be_attacked_box_component.enable_component(ComponentBase.E_IsEnableFactor.Hypno)

## 被压扁
## [character:Character000Base] 发动攻击的角色
func be_flattened(character:Character000Base):
	body.scale.y = 0.4
	shadow.visible = false
	anim_component.stop_anim()
	## 角色死亡不消失
	character_death_not_disappear()
	## 两秒后删除
	await get_tree().create_timer(2.0).timeout
	queue_free()

#endregion

#region 速度修改相关
## 被冰冻减速
func be_ice_decelerate(time:float):
	update_speed_factor(0.5, E_Influence_Speed_Factor.IceDecelerateSpeed)
	body.set_other_color(BodyCharacter.E_ChangeColors.IceColor, Color(0.5, 1, 1))
	if ice_decelerate_timer.time_left < time:
		ice_decelerate_timer.start(time)

## 冰冻减速计时器结束
func _on_ice_decelerate_timer_timeout() -> void:
	update_speed_factor(1.0, E_Influence_Speed_Factor.IceDecelerateSpeed)
	body.set_other_color(BodyCharacter.E_ChangeColors.IceColor, Color(1, 1, 1))

## 被冰冻控制
func be_ice_freeze(time:float, time_ice_end_decelerate:float):
	self.time_ice_end_decelerate = time_ice_end_decelerate
	update_speed_factor(0.0, E_Influence_Speed_Factor.IceFreezeSpeed)
	body.set_other_color(BodyCharacter.E_ChangeColors.IceColor, Color(0.5, 1, 1))
	if ice_freeze_timer.time_left < time:
		ice_freeze_timer.start(time)

## 冰冻控制计时器结束
func _on_ice_freeze_timer_timeout() -> void:
	update_speed_factor(1.0, E_Influence_Speed_Factor.IceFreezeSpeed)
	be_ice_decelerate(time_ice_end_decelerate)

## 取消冰冻减速(火焰豌豆\辣椒)
func cancel_ice():
	ice_freeze_timer.stop()
	_on_ice_freeze_timer_timeout()
	ice_decelerate_timer.stop()
	_on_ice_decelerate_timer_timeout()
	if is_instance_valid(ice_effect):
		ice_effect.queue_free()

#endregion
