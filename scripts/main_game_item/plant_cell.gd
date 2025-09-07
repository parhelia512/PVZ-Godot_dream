extends Control
class_name PlantCell

## 植物的父节点为对应位置的容器节点 plant_container_node
## 底部植物会上下移动
## 如果使用tween控制移动，每帧计算差值控制中间植物上下移动会卡#
## 因此放置底部植物时：
## 将中间植物（norm和shell）的容器节点放到底部植物的容器（底部植物自带的子节点，与植物格子的底部植物容器无关）中
## 底部植物容器会上下移动，从而带动中间植物上下移动
## 中间植物的位置与底部植物的容器位置无关

signal click_cell
signal cell_mouse_enter
signal cell_mouse_exit
## 删除墓碑信号
signal signal_cell_delete_tombstone(plant_cell:PlantCell, tombstone:TombStone)

@onready var button: Button = $Button
## 植物槽底部
@onready var plant_cell_down: Control = $PlantCellDown
## 植物碰撞器位置节点
@onready var plant_area_2d_position: Control = $PlantArea2dPosition


## 植物格子类型
enum PlantCellType{
	Grass,		## 草地
	Pool,		## 水池
	Roof,		## 屋顶/裸地
}
## 当前格子类型
@export var plant_cell_type :PlantCellType = PlantCellType.Grass

## 行和列 PlantCellManager赋值
@export var row_col:Vector2i

@export_group("当前格子的条件")
@export_group("植物种植")
#@export_flags("1 无", "2 草地", "4 花盆", "8 水", "16 睡莲", "32 屋顶/裸地")
var ori_condition:int = 3
## 植物种植地形条件（满足一个即可），默认（无1 + 草地2 = 3）
var curr_condition:int = 3

## 植物在格子中的位置

## 在当前格子中对应位置的植物
@export var plant_in_cell:Dictionary[Global.PlacePlantInCell, Plant000Base] =  {
	Global.PlacePlantInCell.Norm: null,
	Global.PlacePlantInCell.Float: null,
	Global.PlacePlantInCell.Down: null,
	Global.PlacePlantInCell.Shell: null,
}

## 在当前格子中对应位置的容器节点
@onready var plant_container_node:Dictionary =  {
	Global.PlacePlantInCell.Norm: $PlantNormContainer,
	Global.PlacePlantInCell.Shell: $PlantShellContainer,
	Global.PlacePlantInCell.Float: $PlantFloatContainer,
	Global.PlacePlantInCell.Down: $PlantDownContainer,
}

## 在当前格子中对应容器位置的节点初始全局位置,
var plant_postion_node_ori_global_position:Dictionary =  {}

## 是否可以种植普通植物
@export var can_common_plant := true
@export_group("特殊状态，特殊状态下无法种植")
enum E_SpecialState {
	IsTombstone,	# 墓碑
	IsCrater,		# 坑洞
	IsIceRoad,		# 冰道
	IsNoPlantBowling,		# 不能种植（保龄球红线模式不能种植）
}
## 当前特殊状态
@export var curr_special_state:Dictionary[E_SpecialState, bool]

## 当前格子冰道
var curr_ice_roads:Array[IceRoad] = []
## 当前cell的墓碑
var tombstone:TombStone
## 当前cell的坑洞
var crater:DoomShroomCrater

func _ready() -> void:
	## 隐藏按钮样式
	var new_stylebox_normal = $Button.get_theme_stylebox("pressed").duplicate()
	$Button.add_theme_stylebox_override("normal", new_stylebox_normal)

	## 根据格子类型初始化植物种植地形条件
	init_condition()

## 新植物种植
func create_plant(plant_type:Global.PlantType):
	## 创建植物
	var plant_condition:ResourcePlantCondition = Global.get_plant_info(plant_type, Global.PlantInfoAttribute.PlantConditionResource)
	var plant :Plant000Base= Global.get_plant_info(plant_type, Global.PlantInfoAttribute.PlantScenes).instantiate()
	plant.init_plant(Character000Base.E_CharacterInitType.IsNorm, self)
	plant_container_node[plant_condition.place_plant_in_cell].add_child(plant)
	plant_in_cell[plant_condition.place_plant_in_cell] = plant
	plant.signal_character_death.connect(one_plant_free.bind(plant))

	## 种植特效
	var plant_start_effect_scene:Node2D
	## 当前地形为水或者睡莲
	if curr_condition & 8 or curr_condition & 16:
		plant_start_effect_scene = SceneRegistry.PLANT_START_EFFECT_WATER.instantiate()
	else:
		plant_start_effect_scene = SceneRegistry.PLANT_START_EFFECT.instantiate()
	plant.add_child(plant_start_effect_scene)

	## 如果是down位置植物，修改中间植物节点顺序， 提高中间植物和壳的位置,
	if plant_condition.place_plant_in_cell == Global.PlacePlantInCell.Down:
		#plant = plant as PlantDownBase
		## 修改PlantNorm和PlantShell为底部植物节点上下移动节点的子节点
		remove_child(plant_container_node[Global.PlacePlantInCell.Norm])
		plant.down_plant_container.add_child(plant_container_node[Global.PlacePlantInCell.Norm])
		plant_container_node[Global.PlacePlantInCell.Norm].global_position = plant_postion_node_ori_global_position[Global.PlacePlantInCell.Norm] - plant.plant_up_position

		remove_child(plant_container_node[Global.PlacePlantInCell.Shell])
		plant.down_plant_container.add_child(plant_container_node[Global.PlacePlantInCell.Shell])
		plant_container_node[Global.PlacePlantInCell.Shell].global_position = plant_postion_node_ori_global_position[Global.PlacePlantInCell.Shell] - plant.plant_up_position

	## 更新植物代替受伤
	update_plant_replace_be_attack()

	return plant

## 获取种植新植物时植物虚影的位置
func get_new_plant_static_shadow_global_position(place_plant_in_cell:Global.PlacePlantInCell):
	return plant_container_node[place_plant_in_cell].global_position


## 植物死亡
func one_plant_free(plant:Plant000Base):
	var curr_plant_condition :ResourcePlantCondition = Global.get_plant_info(plant.plant_type, Global.PlantInfoAttribute.PlantConditionResource)

	plant_in_cell[curr_plant_condition.place_plant_in_cell] = null

	## 如果是down位置植物，下降中间植物和壳的位置，修改节点结构
	if curr_plant_condition.place_plant_in_cell == Global.PlacePlantInCell.Down:

		## 中间植物的节点修改回来
		plant.down_plant_container.remove_child(plant_container_node[Global.PlacePlantInCell.Norm])
		add_child(plant_container_node[Global.PlacePlantInCell.Norm])
		plant_container_node[Global.PlacePlantInCell.Norm].global_position = plant_postion_node_ori_global_position[Global.PlacePlantInCell.Norm]

		plant.down_plant_container.remove_child(plant_container_node[Global.PlacePlantInCell.Shell])
		add_child(plant_container_node[Global.PlacePlantInCell.Shell])
		plant_container_node[Global.PlacePlantInCell.Shell].global_position = plant_postion_node_ori_global_position[Global.PlacePlantInCell.Shell]


	##如果植物死亡时鼠标在当前植物格子中，重新发射鼠标进入格子信号检测种植
	if is_mouse_in_ui(button):
		_on_button_mouse_entered()
	## 更新植物代替受伤
	update_plant_replace_be_attack()

## 根据当前格子类型初始化当前格子状态
func init_condition():
	match plant_cell_type:
		PlantCellType.Grass:
			ori_condition = 3
			curr_condition = 3

		PlantCellType.Pool:
			ori_condition = 9
			curr_condition = 9

		PlantCellType.Roof:
			ori_condition = 9
			curr_condition = 33

	## 等待一帧后，赋值底部全局位置
	## 可能是由于其父节点容器需要这一帧对该节点位置移动，
	await get_tree().process_frame
	### 在当前格子中对应位置的节点初始全局位置,植物放在该节点下
	for place_plant_in_cell in plant_container_node.keys():
		plant_postion_node_ori_global_position[place_plant_in_cell] = plant_container_node[place_plant_in_cell].global_position

## 改变特殊状态
func update_special_state(value:bool, change_specila_state:E_SpecialState):
	curr_special_state[change_specila_state] = value
	_update_state()

## 更新状态
func _update_state():
	##是否全为false(无特殊状态，可以种植)
	can_common_plant = curr_special_state.values().all(func(v): return not v)

	##如果更新状态时鼠标在当前植物格子中，重新发射鼠标进入格子信号检测种植
	if is_mouse_in_ui(button):
		_on_button_mouse_entered()

## 荷叶种植/死亡时调用
func _lily_pad_change_condition():
	## 切换荷叶地形
	curr_condition = curr_condition ^ 16
	## 切换水池地形
	curr_condition = curr_condition ^ 8

## 花盆种植/死亡时调用
func _flower_pot_change_condition():
	## 如果当前是花盆地形，设置地形为原始地形
	if curr_condition & 4:
		curr_condition = ori_condition

	## 如果当前不是花盆地形，设置当前地形为花盆地形
	else:
		curr_condition = 4

## 底部植物种植或死亡时改变地形
func down_plant_change_condition(is_water:bool):
	if is_water:
		_lily_pad_change_condition()
	else:
		_flower_pot_change_condition()

#region 特殊状态
#region 墓碑相关
## 创建墓碑
func create_tombstone(tombstone:TombStone):
	## 被墓碑顶掉的植物
	var all_place_plant_in_cell_be_tombstone = [
		Global.PlacePlantInCell.Norm,
		Global.PlacePlantInCell.Down,
		Global.PlacePlantInCell.Shell
	]
	## 删除对应位置植物
	for place_plant_in_cell in all_place_plant_in_cell_be_tombstone:
		## 如果存在植物
		if plant_in_cell[place_plant_in_cell]:
			plant_in_cell[place_plant_in_cell].character_death()

	self.tombstone = tombstone
	tombstone.init_tombstone(self)
	add_child(tombstone)
	tombstone.position = Vector2(size.x / 2, size.y)
	update_special_state(true, E_SpecialState.IsTombstone)

## 开始吞噬墓碑，墓碑是墓碑吞噬者调用该函数
func start_eat_tombstone():
	tombstone.start_be_grave_buster_eat()

## 吞噬墓碑失败
func failure_eat_tombstone():
	tombstone.failure_eat_tombstone()

## 刪除墓碑，墓碑是墓碑吞噬者调用该函数
func delete_tombstone():
	if tombstone.new_zombie:
		GlobalUtils.child_node_change_parent(tombstone.new_zombie, MainGameDate.all_zombie_rows[tombstone.new_zombie.lane])
	signal_cell_delete_tombstone.emit(self, tombstone)
	tombstone.queue_free()
	## 等到墓碑被删除后，下一帧更新（如果鼠标拿着新植物在当前格子中，可以更新）
	await get_tree().process_frame
	update_special_state(false, E_SpecialState.IsTombstone)
#endregion

#region 坑洞相关
## 创建坑洞
func create_crater():
	self.crater = SceneRegistry.DOOM_SHROOM_CRATER.instantiate()
	add_child(crater)
	crater.init_crater(1, self)

	update_special_state(true, E_SpecialState.IsCrater)

## 坑洞调用该函数，坑洞是自己消失后调用该函数
func delete_crater():
	crater.queue_free()

	update_special_state(false, E_SpecialState.IsCrater)

#endregion

#region 冰道相关
func add_new_ice_road(new_ice_road:IceRoad):
	curr_ice_roads.append(new_ice_road)
	update_special_state(true, E_SpecialState.IsIceRoad)
	new_ice_road.signal_ice_road_disappear.connect(del_new_ice_road.bind(new_ice_road))

## 删除冰道
func del_new_ice_road(new_ice_road):
	curr_ice_roads.erase(new_ice_road)
	if curr_ice_roads.is_empty():
		update_special_state(false, E_SpecialState.IsIceRoad)

#endregion

#region 保龄球种植
## 设置保龄球不能种植
func set_bowling_no_plant():
	update_special_state(true, E_SpecialState.IsNoPlantBowling)

#endregion

#endregion

#region 鼠标交互相关
func _on_button_pressed() -> void:
	click_cell.emit(self)

func _on_button_mouse_entered() -> void:
	cell_mouse_enter.emit(self)

func _on_button_mouse_exited() -> void:
	cell_mouse_exit.emit(self)


func is_mouse_in_ui(control_node: Control) -> bool:
	return control_node.get_rect().has_point(control_node.get_local_mouse_position())

## 返回当前被铲子威胁的植物
func return_plant_be_shovel_look():
	## 如果当前格子有植物,根据位置选择植物，若位置没有植物，选择别的植物
	if get_curr_plant_num:
		var plant_place_be_shovel = get_plant_place_from_mouse_pos()
		return return_plant_null_res(plant_place_be_shovel)
	else:
		null

## 如果当前位置没有植物时，返回顺位植物,递归调用，知道返回植物
## is_loop 表示上次是否判断过是否为norm，shell循环
## 写代码的时候没有float植物，不确定是否有问题
func return_plant_null_res(plant_place_be_shovel:Global.PlacePlantInCell, is_loop:=false):
	match plant_place_be_shovel:
		Global.PlacePlantInCell.Norm:
			if plant_in_cell[Global.PlacePlantInCell.Norm]:
				return plant_in_cell[Global.PlacePlantInCell.Norm]
			else:
				if is_loop:
					return return_plant_null_res(Global.PlacePlantInCell.Down, true)
				else:
					return return_plant_null_res(Global.PlacePlantInCell.Shell, true)

		Global.PlacePlantInCell.Shell:
			if plant_in_cell[Global.PlacePlantInCell.Shell]:
				return plant_in_cell[Global.PlacePlantInCell.Shell]
			else:
				if is_loop:
					return return_plant_null_res(Global.PlacePlantInCell.Down, true)
				else:
					return return_plant_null_res(Global.PlacePlantInCell.Norm, true)

		Global.PlacePlantInCell.Float:
			if plant_in_cell[Global.PlacePlantInCell.Float]:
				return plant_in_cell[Global.PlacePlantInCell.Float]
			else:
				return return_plant_null_res(Global.PlacePlantInCell.Norm)

		Global.PlacePlantInCell.Down:
			if plant_in_cell[Global.PlacePlantInCell.Down]:
				return plant_in_cell[Global.PlacePlantInCell.Down]
			else:
				return return_plant_null_res(Global.PlacePlantInCell.Float)

## 铲子进入该shell时，判断当前格子是否有多个植物,
## 有多个植物时，会随鼠标移动更新当前被铲子看的植物
## 判断时忽略down植物
func get_curr_plant_num()->int:
	var curr_plant_num = 0
	if plant_in_cell[Global.PlacePlantInCell.Norm]:
		curr_plant_num += 1
	if plant_in_cell[Global.PlacePlantInCell.Shell]:
		curr_plant_num += 1
	if plant_in_cell[Global.PlacePlantInCell.Float]:
		curr_plant_num += 1
	if plant_in_cell[Global.PlacePlantInCell.Down]:
		curr_plant_num += 1
	return curr_plant_num

## 鼠标移动检测
#func _input(event):
	#if event is InputEventMouseMotion:
		#_check_mouse_panel_region(event.position)
#
## 根据鼠标在当前格子中的位置，返回应该被铲除的植物
func get_plant_place_from_mouse_pos():
	var local_pos = button.get_local_mouse_position()
	var height = button.size.y
	if local_pos.y < height / 3:
		return Global.PlacePlantInCell.Float
	elif local_pos.y < height * 2 / 3:
		return Global.PlacePlantInCell.Norm
	else:
		return Global.PlacePlantInCell.Shell

#endregion

#region 更新植物代替受伤
## 种植新植物或植物死亡时调用
func update_plant_replace_be_attack():
	## 底部植物和正常植物
	if is_instance_valid(plant_in_cell[Global.PlacePlantInCell.Down]) and is_instance_valid(plant_in_cell[Global.PlacePlantInCell.Norm]):
		plant_in_cell[Global.PlacePlantInCell.Down].curr_replace_be_attack_plant = plant_in_cell[Global.PlacePlantInCell.Norm]
	## 正常植物和壳类植物
	if is_instance_valid(plant_in_cell[Global.PlacePlantInCell.Norm]) and is_instance_valid(plant_in_cell[Global.PlacePlantInCell.Shell]):
		plant_in_cell[Global.PlacePlantInCell.Norm].curr_replace_be_attack_plant = plant_in_cell[Global.PlacePlantInCell.Shell]
	## 底部植物和壳类植物
	if is_instance_valid(plant_in_cell[Global.PlacePlantInCell.Down]) and is_instance_valid(plant_in_cell[Global.PlacePlantInCell.Shell]):
		plant_in_cell[Global.PlacePlantInCell.Down].curr_replace_be_attack_plant = plant_in_cell[Global.PlacePlantInCell.Shell]
#endregion
