extends Node
## 手持管理器，角色（植物僵尸）
class_name HM_Character

## 植物临时挂载节点
@onready var temporary_plants: Node2D = %TemporaryPlants
## 僵尸临时挂载节点
@onready var temporary_zombies: Node2D = %TemporaryZombies

## 当前卡片
var curr_card:Card = null
## 手持静态角色
var characte_static:Node2D
## 格子静态角色虚影
var characte_static_shadow:Node2D
## 植物种植条件
var plant_condition:ResourcePlantCondition
## 僵尸种植行条件
var zombie_row_type:Global.ZombieRowType
## 虚影在格子中，即可以种植
var is_shadow_in_cell:=false

## 柱子模式
var is_mode_column := false
## 柱子模式虚影
var characte_static_shadow_colum : Array[Node2D]

func init_hm_character(game_para:ResourceLevelData):
	self.is_mode_column = game_para.is_mode_column

func character_process() -> void:
	characte_static.global_position = get_viewport().get_mouse_position()

## 点击卡片
func click_card(card:Card) -> void:
	## 清除之前数据
	if curr_card != null:
		_clear_curr_data()
	## 新植物数据
	curr_card = card
	## 植物
	if curr_card.card_plant_type != Global.PlantType.Null:
		plant_condition = Global.get_plant_info(curr_card.card_plant_type, Global.PlantInfoAttribute.PlantConditionResource)
		## 静态植物以及植物虚影
		characte_static = card.character_static.duplicate()
		characte_static.get_child(0).scale = Vector2.ONE
		characte_static_shadow = characte_static.get_child(0).duplicate()
		characte_static_shadow.modulate.a = 0
		characte_static.z_index = 1

		temporary_plants.add_child(characte_static)
		temporary_plants.add_child(characte_static_shadow)

		if click_card_column:
			click_card_column()
	## 僵尸
	else:
		zombie_row_type = Global.get_zombie_info(curr_card.card_zombie_type, Global.ZombieInfoAttribute.ZombieRowType)
		## 静态僵尸以及僵尸虚影
		characte_static = card.character_static.duplicate()
		characte_static.get_child(0).scale = Vector2.ONE
		characte_static_shadow = characte_static.get_child(0).duplicate()
		characte_static_shadow.modulate.a = 0
		characte_static.z_index = 1

		temporary_zombies.add_child(characte_static)
		temporary_zombies.add_child(characte_static_shadow)

		if click_card_column:
			click_card_column()

## 清除数据
func _clear_curr_data():
	is_shadow_in_cell = false
	curr_card = null
	characte_static.queue_free()
	characte_static_shadow.queue_free()
	plant_condition = null
	zombie_row_type = Global.ZombieRowType.Land
	if is_mode_column:
		_clear_curr_data_column()

## 鼠标进入cell
func mouse_enter(plant_cell:PlantCell):
	is_shadow_in_cell = _update_cell_shadow(plant_cell, characte_static_shadow)
	if is_shadow_in_cell and is_mode_column:
		_mouse_enter_column(plant_cell)

## 更新植物格子虚影,返回是否能种植
func _update_cell_shadow(plant_cell:PlantCell, characte_static_shadow:Node2D) -> bool:
	## 植物
	if curr_card.card_plant_type != 0:
		## 如果是普通植物并且当前格子可以种植普通植物
		if not plant_condition.is_special_plants and plant_cell.can_common_plant:
			## 如果地形当前格子地形符合 并且 当前格子对应的植物位置为空
			if plant_condition.plant_condition & plant_cell.curr_condition and plant_cell.plant_in_cell[plant_condition.place_plant_in_cell] == null:
				characte_static_shadow.global_position = plant_cell.get_new_plant_static_shadow_global_position(plant_condition.place_plant_in_cell)
				characte_static_shadow.modulate.a = 0.5
				return true
			else:
				characte_static_shadow.modulate.a = 0
				return false

		## 如果是特殊植物，特殊植物调用自己的方法判断是否可以种植
		elif plant_condition.is_special_plants:
			if plant_condition.judge_special_plants_condition(plant_cell):
				characte_static_shadow.global_position = plant_cell.get_new_plant_static_shadow_global_position(plant_condition.place_plant_in_cell)
				characte_static_shadow.modulate.a = 0.5
				return true
			else:
				characte_static_shadow.modulate.a = 0
				return false
		## 如果都不是，不能种植
		else:
			characte_static_shadow.modulate.a = 0
			return false
	## 僵尸
	else:
		## 如果当前格子不能种植僵尸
		if not plant_cell.can_common_zombie:
			return false
		## 如果不是双地形
		if zombie_row_type != Global.ZombieRowType.Both:
			if zombie_row_type == MainGameDate.all_zombie_rows[plant_cell.row_col.x].zombie_row_type:
				characte_static_shadow.global_position = Vector2(
					plant_cell.global_position.x + plant_cell.size.x/2,
					MainGameDate.all_zombie_rows[plant_cell.row_col.x].zombie_create_position.global_position.y
				)
				characte_static_shadow.modulate.a = 0.5
				return true
			else:
				characte_static_shadow.modulate.a = 0
				return false
		else:
			characte_static_shadow.global_position = Vector2(
				plant_cell.global_position.x + plant_cell.size.x/2,
				MainGameDate.all_zombie_rows[plant_cell.row_col.x].zombie_create_position.global_position.y
			)
			characte_static_shadow.modulate.a = 0.5
			return true

## 鼠标移出cell
func mouse_exit(plant_cell:PlantCell):
	characte_static_shadow.modulate.a = 0
	if is_mode_column:
		_mouse_exit_column()

## 点击种植或铲掉植物
func click_cell(plant_cell:PlantCell):
	if is_shadow_in_cell:
		if curr_card.card_plant_type != 0:
			plant_cell.create_plant(curr_card.card_plant_type)
		else:
			MainGameDate.zombie_manager.create_norm_zombie(
				curr_card.card_zombie_type,
				MainGameDate.all_zombie_rows[plant_cell.row_col.x],
				Character000Base.E_CharacterInitType.IsNorm,
				plant_cell.row_col.x,
				-1,
				characte_static_shadow.global_position - MainGameDate.all_zombie_rows[plant_cell.row_col.x].global_position
			)

		## 卡片种植完成后发射信号
		curr_card.signal_card_use_end.emit()

		if is_mode_column:
			_click_cell_column(plant_cell)

## 退出当前状态
func exit_status():
	_clear_curr_data()


#region 柱子模式额外操作函数
## 柱子模式 点击卡片产生多余植物虚影
func click_card_column() -> void:
	if curr_card.card_plant_type != 0:
		for plant_cell_i in range(MainGameDate.row_col.x):
			var column_characte_static_shadow = characte_static_shadow.duplicate()
			column_characte_static_shadow.modulate.a = 0
			temporary_plants.add_child(column_characte_static_shadow)
			characte_static_shadow_colum.append(column_characte_static_shadow)
	else:
		for zombie_rows_i in range(MainGameDate.all_zombie_rows.size()):
			var column_characte_static_shadow = characte_static_shadow.duplicate()
			column_characte_static_shadow.modulate.a = 0
			temporary_zombies.add_child(column_characte_static_shadow)
			characte_static_shadow_colum.append(column_characte_static_shadow)

## 柱子模式 鼠标进入判断其他格子是否可以种植，产生虚影
func _mouse_enter_column(plant_cell:PlantCell):
	for plant_cell_i in range(MainGameDate.row_col.x):
		if plant_cell_i == plant_cell.row_col.x:
			continue

		## 判断是否产生虚影
		_update_cell_shadow(
			MainGameDate.all_plant_cells[plant_cell_i][plant_cell.row_col.y],\
			characte_static_shadow_colum[plant_cell_i]
		)

## 柱子模式 鼠标移出cell
func _mouse_exit_column():
	for _characte_static_shadow in characte_static_shadow_colum:
		_characte_static_shadow.modulate.a = 0

## 柱子模式 点击种植或铲掉植物
func _click_cell_column(plant_cell:PlantCell):

	if curr_card.card_plant_type != 0:
		for i in range(characte_static_shadow_colum.size()):
			## 当前格子的图像透明
			var _characte_static_shadow = characte_static_shadow_colum[i]
			if _characte_static_shadow.modulate.a != 0:
				var _plant_cell:PlantCell = MainGameDate.all_plant_cells[i][plant_cell.row_col.y]
				_plant_cell.create_plant(curr_card.card_plant_type)
	else:
		for i in range(characte_static_shadow_colum.size()):
			## 当前格子的图像透明
			var _characte_static_shadow = characte_static_shadow_colum[i]
			if _characte_static_shadow.modulate.a != 0:
				var _plant_cell:PlantCell = MainGameDate.all_plant_cells[i][plant_cell.row_col.y]
				MainGameDate.zombie_manager.create_norm_zombie(
					curr_card.card_zombie_type,
					MainGameDate.all_zombie_rows[_plant_cell.row_col.x],
					Character000Base.E_CharacterInitType.IsNorm,
					_plant_cell.row_col.x,
					-1,
					Vector2(_characte_static_shadow.global_position.x - MainGameDate.all_zombie_rows[_plant_cell.row_col.x].global_position.x,
						MainGameDate.all_zombie_rows[_plant_cell.row_col.x].zombie_create_position.position.y
					)
				)

## 柱子模式 清除数据
func _clear_curr_data_column():
	for _characte_static_shadow in characte_static_shadow_colum:
		_characte_static_shadow.queue_free()
	characte_static_shadow_colum.clear()

#endregion
