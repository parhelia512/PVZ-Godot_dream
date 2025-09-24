extends ComponentBase
class_name HpStageChangeComponent
## 血量阶段变化组件,坚果和南瓜头使用
## 血量到达临界值时变化

@onready var owner_character: Character000Base = owner
@onready var hp_component: HpComponent = %HpComponent

@export_group("血量临界值(两者个数必须对应)")
@export_subgroup("本体血量临界值(血量临界值数组默认为空（2个）即可)")
## 血量临界值数组，从满血到死亡顺序,默认为空即可
@export var boundary_value_hp:Array[int]
## 每阶段血量改变的精灵节点（默认有两个阶段：掉手、掉头）
@export var body_change:Array[ResourceBodyChange]
## 当前血量阶段
var curr_hp_stage := -1:
	set(value):
		curr_hp_stage = value
		signal_hp_stage_change.emit(curr_hp_stage)

signal signal_hp_stage_change(curr_hp_stage:int)

@export_subgroup("一类防具(血量临界值数组默认为空（3个）即可)")
## 血量临界值数组，从满血到死亡顺序,默认为空即可
@export var boundary_value_hp_armor1:Array[int]
## 每阶段血量改变的精灵节点（默认有两个阶段：掉手、掉头）
@export var body_change_armor1:Array[ResourceBodyChange]
## 当前血量阶段
var curr_hp_armor1_stage := -1

@export_subgroup("二类防具(血量临界值数组默认为空（3个）即可)")
## 血量临界值数组，从满血到死亡顺序,默认为空即可
@export var boundary_value_hp_armor2:Array[int]
## 每阶段血量改变的精灵节点（默认有两个阶段：掉手、掉头）
@export var body_change_armor2:Array[ResourceBodyChange]
## 当前血量阶段
var curr_hp_armor2_stage := -1

## 死亡时body是否无变化(炸弹\死亡时直接消失\TODO:小推车)
var is_no_change:=false

func _ready() -> void:
	## 初始化参数
	if boundary_value_hp.is_empty():
		boundary_value_hp.append(hp_component.max_hp * 2 / 3 - 1)	## 掉手
		boundary_value_hp.append(hp_component.max_hp * 1 / 3 - 1)	## 掉头
		if owner is Plant000Base:
			printerr("植物使用血量阶段变化组件需对对`boundary_value_hp`赋值")

	## 修改死亡临界值
	if boundary_value_hp[-1] != 0:
		hp_component.set_death_hp(boundary_value_hp[-1])

	## 只有僵尸血量组件会初始化防具参数
	if hp_component is HpComponentZombie:
		## 初始化防具参数
		if boundary_value_hp_armor1.is_empty() and hp_component.max_hp_armor1 != 0:
			boundary_value_hp_armor1.append(hp_component.max_hp_armor1 * 2 / 3 - 1)
			boundary_value_hp_armor1.append(hp_component.max_hp_armor1 * 1 / 3 - 1)
			boundary_value_hp_armor1.append(0)

		if boundary_value_hp_armor2.is_empty() and hp_component.max_hp_armor2 != 0:
			boundary_value_hp_armor2.append(hp_component.max_hp_armor2 * 2 / 3 - 1)
			boundary_value_hp_armor2.append(hp_component.max_hp_armor2 * 1 / 3 - 1)
			boundary_value_hp_armor2.append(0)

#region 本体body变化
## 判断body是否需要变化
## curr_hp: 当前剩余血量
func judge_body_change(curr_hp:int, is_drop:=true):
	## 死亡并且无变化
	if is_no_change and curr_hp <= boundary_value_hp[-1]:
		return
	if curr_hp_stage == boundary_value_hp.size() - 1:
		return
	## 循环数组
	for i in range(boundary_value_hp.size()):
		if curr_hp_stage < i and curr_hp <= boundary_value_hp[i]:
			curr_hp_stage = i
			if body_change[i] == null:
				continue
			for j in range(body_change[i].sprite_change.size()):
				var sprite_change:Sprite2D = get_node(body_change[i].sprite_change[j])
				sprite_change.texture = body_change[i].sprite_change_texture[j]
				#print("改变")

			for j in range(body_change[i].sprite_appear.size()):
				var sprite_appear:Node2D = get_node(body_change[i].sprite_appear[j])
				sprite_appear.visible = true

			for j in range(body_change[i].sprite_disappear.size()):
				var sprite_disappear:Node2D = get_node(body_change[i].sprite_disappear[j])
				sprite_disappear.visible = false

			## 如果有掉落节点
			if body_change[i].node_drop:
				if not is_drop:
					continue
				var drop:ZombieDropBase = get_node(body_change[i].node_drop)
				drop.acitvate_it()
#endregion

#region 防具body变化
## 防具血量变化判断,判断body是否需要变化
## curr_hp: 当前剩余血量
func judge_body_change_armor(curr_hp_arm:int, curr_hp:int, is_drop:bool=true, is_armor1:bool=true):
	var curr_hp_stage:int = curr_hp_armor1_stage
	var boundary_value_hp:Array[int] = boundary_value_hp_armor1
	var body_change:Array[ResourceBodyChange] = body_change_armor1
	if not is_armor1:
		curr_hp_stage = curr_hp_armor2_stage
		boundary_value_hp = boundary_value_hp_armor2
		body_change = body_change_armor2

	if is_no_change and curr_hp <= boundary_value_hp[-1]:
		return
	if curr_hp_stage == boundary_value_hp.size() - 1:
		return
	## 循环数组
	for i in range(boundary_value_hp.size()):
		if curr_hp_stage < i and curr_hp_arm <= boundary_value_hp[i]:
			#print("当前血量状态：", curr_hp_stage, "小于状态：", i)
			#print("当前血量：", curr_hp_stage, "小于状态：", i)
			curr_hp_stage = i
			if is_armor1:
				curr_hp_armor1_stage = curr_hp_stage
			else:
				curr_hp_armor2_stage = curr_hp_stage

			if body_change[i] == null:
				break

			for j in range(body_change[i].sprite_change.size()):
				var sprite_change:Sprite2D = get_node(body_change[i].sprite_change[j])
				sprite_change.texture = body_change[i].sprite_change_texture[j]

			for j in range(body_change[i].sprite_appear.size()):
				var sprite_appear:Node2D = get_node(body_change[i].sprite_appear[j])
				sprite_appear.visible = true

			for j in range(body_change[i].sprite_disappear.size()):
				var sprite_disappear:Node2D = get_node(body_change[i].sprite_disappear[j])
				sprite_disappear.visible = false

			## 如果有掉落节点
			if body_change[i].node_drop:
				if not is_drop:
					continue
				var drop:ZombieDropBase = get_node(body_change[i].node_drop)
				drop.acitvate_it()
#endregion
