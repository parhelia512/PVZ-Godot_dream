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

signal cell_delete_tombstone	## 删除墓碑信号

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

## 行和列
@export var row_col:Vector2i


@export_group("当前格子的条件")
@export_group("植物种植")
@export_flags("1 无", "2 草地", "4 花盆", "8 水", "16 睡莲", "32 屋顶/裸地") 
var ori_condition:int = 3
## 植物种植地形条件（满足一个即可），默认（无1 + 草地2 = 3）
var curr_condition:int = 3

## 植物在格子中的位置

## 在当前格子中对应位置的植物
@export var plant_in_cell:Dictionary =  {
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
@export_group("特殊状态")

## 是否有墓碑
@export var is_tombstone := false:
	get:
		return is_tombstone
	set(v):
		is_tombstone = v
		_update_state()
## 是否有坑洞
@export var is_crater := false:
	get:
		return is_crater
	set(v):
		is_crater = v
		_update_state()
## 是否有冰道
@export var is_ice_road :=false:
	get:
		return is_ice_road
	set(v):
		is_ice_road = v
		_update_state()

## 当前格子冰道
var curr_ice_roads :Array[IceRoad] = []

## 当前cell的墓碑
var tombstone:TombStone
## 当前cell的坑洞
var crater:DoomShroomCrater
## 毁灭菇坑洞场景
const doom_shroom_scenes:PackedScene =  preload("res://scenes/fx/doom_shroom_crater.tscn")


func _ready() -> void:
	## 隐藏按钮样式
	var new_stylebox_normal = $Button.get_theme_stylebox("pressed").duplicate()
	$Button.add_theme_stylebox_override("normal", new_stylebox_normal)
	
	## 根据格子类型初始化植物种植地形条件
	init_condition()
	
## 新植物种植
func add_plant(plant:PlantBase):
	plant_in_cell[plant.plant_condition.place_plant_in_cell] = plant
	plant_container_node[plant.plant_condition.place_plant_in_cell].add_child(plant)
	
	## 如果是down位置植物，修改中间植物节点顺序， 提高中间植物和壳的位置,
	if plant.plant_condition.place_plant_in_cell == Global.PlacePlantInCell.Down:
		plant = plant as PlantDownBase
		## 修改PlantNorm和PlantShell为底部植物节点上下移动节点的子节点
		remove_child(plant_container_node[Global.PlacePlantInCell.Norm])
		plant.down_plant_container.add_child(plant_container_node[Global.PlacePlantInCell.Norm])
		plant_container_node[Global.PlacePlantInCell.Norm].global_position = plant_postion_node_ori_global_position[Global.PlacePlantInCell.Norm] - plant.plant_up_position
		
		remove_child(plant_container_node[Global.PlacePlantInCell.Shell])
		plant.down_plant_container.add_child(plant_container_node[Global.PlacePlantInCell.Shell])
		plant_container_node[Global.PlacePlantInCell.Shell].global_position = plant_postion_node_ori_global_position[Global.PlacePlantInCell.Shell] - plant.plant_up_position
	
	plant.init_plant(row_col, self)
	
		
## 获取种植新植物时植物虚影的位置
func get_new_plant_static_shadow_global_position(place_plant_in_cell:Global.PlacePlantInCell):

	return plant_container_node[place_plant_in_cell].global_position

## 植物死亡
func one_plant_free(plant:PlantBase):
	plant_in_cell[plant.plant_condition.place_plant_in_cell] = null
	
	## 如果是down位置植物，下降中间植物和壳的位置，修改节点结构
	if plant.plant_condition.place_plant_in_cell == Global.PlacePlantInCell.Down:
		
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

# 根据当前格子类型初始化当前格子状态
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


## 更新状态
func _update_state():
	# 先判断特殊状态(有墓碑、坑洞或冰道)
	if is_tombstone or is_crater or is_ice_road:
		can_common_plant = false
	else:
		can_common_plant = true
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
	
#region 墓碑相关
## 创建墓碑
func create_tombstone(tombstone:TombStone):
	self.tombstone = tombstone
	add_child(tombstone)
	tombstone.position = Vector2(39,48)
	is_tombstone = true

## 开始吞噬墓碑，墓碑是墓碑吞噬者调用该函数
func start_tombstone():
	tombstone.start_be_grave_buster_eat()


## 刪除墓碑，墓碑是墓碑吞噬者调用该函数
func delete_tombstone():
	if tombstone.new_zombie:
		tombstone.change_zombie_parent(tombstone.new_zombie)
		
	tombstone.queue_free()
	is_tombstone = false
	## 像hand_manager发射信号
	cell_delete_tombstone.emit(self, tombstone)
#endregion

#region 坑洞相关
## 创建坑洞
func create_crater():
	self.crater = doom_shroom_scenes.instantiate()
	add_child(crater)
	crater.init_crater(1, self)
	is_crater = true

## 坑洞调用该函数，坑洞是自己消失后调用该函数
func delete_crater():
	crater.queue_free()
	is_crater = false

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
	
## 如果当前位置为空时，返回顺位植物,递归调用，知道返回植物
## is_loop 表示上次是否判断过是否为norm，shell循环
## 写代码的时候有float植物，不确定是否有问题
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


#region 冰道相关
#TODO:测试完删除
func add_new_ice_road(new_ice_road):
	if new_ice_road in curr_ice_roads:
		print("当前冰道已在该植物格子，不应该出现该句,后面一直不出现该句可以删除")
	
	else:
		curr_ice_roads.append(new_ice_road)
		if not is_ice_road:
			is_ice_road = true


## 删除冰道
func del_new_ice_road(new_ice_road):
	curr_ice_roads.erase(new_ice_road)
	if curr_ice_roads.is_empty():
		is_ice_road = false
		
#endregion
