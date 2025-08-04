extends Control
class_name PlantCellGarden

## 当前格子的花园背景
@export var curr_garden_bg_type:GardenManager.GardenBgType
var curr_bg_page:=0
## 当前格子植物种类
@export var curr_plant_type:Global.PlantType = Global.PlantType.Null

## 在当前格子的植物
@export var plant_in_cell:PlantGarden
var flower_pot :FlowerPotGarden
var is_shadow := false

# 花盆种植后植物提升的位移，水生植物修改
var plant_up_position = Vector2(0, 15)

## 在当前格子中对应位置的容器节点
@onready var plant_container_node:Dictionary =  {
	Global.PlacePlantInCell.Norm: $PlantNormContainer,
	Global.PlacePlantInCell.Shell: $PlantShellContainer,
	Global.PlacePlantInCell.Float: $PlantFloatContainer,
	Global.PlacePlantInCell.Down: $PlantDownContainer,
}

## 在当前格子中对应容器位置的节点初始全局位置,
var plant_postion_node_ori_global_position:Dictionary =  {}
## 在当前格子中对应容器位置的节点初始位置,
var plant_postion_node_ori_position:Dictionary =  {}

## 花盆
const GARDEN_FLOWER_POT = preload("res://scenes/garden/garden_flower_pot.tscn")

## 发芽状态下的发芽植物
var sprout:PlantGarden
## 发芽植物场景
const ZEN_GARDEN_SPROUT = preload("res://scenes/garden/ZenGarden_sprout.tscn")

## 当前植物是否被手套拿起来
var glove:GardenGlove


func _ready() -> void:
	## 先获取容器原始位置
	for place_plant_in_cell in plant_container_node.keys():
		plant_postion_node_ori_global_position[place_plant_in_cell] = plant_container_node[place_plant_in_cell].global_position
		plant_postion_node_ori_position[place_plant_in_cell] = plant_container_node[place_plant_in_cell].position
	
	
## 植物虚影
func init_curr_plant_cell_shadow(curr_plant_cell_data:Dictionary):
	init_curr_plant_cell(curr_plant_cell_data)
	plant_cell_shadow()


## 植物虚影固定为真实植物
func shadow_fixed():
	plant_cell_shadow_end()


func init_curr_plant_cell(curr_plant_cell_data:Dictionary, bg_type:=-1, page:=-1):
	## 当前背景页初始化当前植物格子
	if bg_type != -1 and page != -1:
		curr_garden_bg_type = bg_type
		curr_bg_page = page
	if curr_plant_cell_data:
		
		## 如果是发芽状态
		if curr_plant_cell_data["curr_growth_stage"] == PlantGarden.GrowthStage.Sprout:
			### 植物
			sprout = ZEN_GARDEN_SPROUT.instantiate()
			sprout.plant_cell = self
			_add_new_plant(sprout, Global.PlacePlantInCell.Norm, 2, curr_plant_cell_data)
			
		else:
			var curr_plant_type = curr_plant_cell_data["curr_plant_type"]
			## 植物
			var curr_plant_show :PlantGarden = Global.get_plant_info(curr_plant_type, Global.PlantInfoAttribute.PlantShowScenes).instantiate()

			## 植物种植条件
			var curr_plant_new_plant_condition = Global.get_plant_info(curr_plant_type, Global.PlantInfoAttribute.PlantConditionResource)
			var curr_plant_place:Global.PlacePlantInCell = curr_plant_new_plant_condition.place_plant_in_cell
			var curr_plant_condition:int = curr_plant_new_plant_condition.plant_condition
			## 如果是Down类植物，修改为Norm类植物
			if curr_plant_place == Global.PlacePlantInCell.Down:
				curr_plant_place = Global.PlacePlantInCell.Norm
			
			_add_new_plant(curr_plant_show, curr_plant_place, curr_plant_condition, curr_plant_cell_data)
	
## 发芽升级为新植物
func sprout_up_new_plant():
	var curr_plant_cell_data:Dictionary = plant_in_cell.get_curr_plant_data()
	print(curr_plant_cell_data)
	plant_in_cell.queue_free()
	init_curr_plant_cell(curr_plant_cell_data)
	## 如果当前被手套拿起
	if glove:
		glove.update_shadow_plant_cell(curr_plant_cell_data)

func init_new_plant_cell():
	## 植物
	sprout = ZEN_GARDEN_SPROUT.instantiate()
	sprout.plant_cell = self
	_add_new_plant(sprout)
	
func _add_new_plant(new_plant:PlantGarden, curr_plant_place:Global.PlacePlantInCell = Global.PlacePlantInCell.Norm, curr_plant_condition:int = 2, curr_plant_cell_data:Dictionary={}):
	plant_in_cell = new_plant
	
	# 花盆
	plant_up_position = Vector2(0, 15)
	var is_last_flower_pot:bool = flower_pot != null
	
	## 如果当前没有花盆（发芽升级）
	if not is_last_flower_pot:
		flower_pot = GARDEN_FLOWER_POT.instantiate()
		plant_container_node[Global.PlacePlantInCell.Down].add_child(flower_pot)
		
		match curr_garden_bg_type:
			GardenManager.GardenBgType.GreenHouse:
				pass
				
			GardenManager.GardenBgType.MushroomGraden:
				## 如果植物种是陆地植物
				if curr_plant_condition & 2:
					flower_pot.update_body_visible(false)
				else:
					flower_pot.update_body_visible(true)
					
			GardenManager.GardenBgType.Aquarium:
				flower_pot.update_body_visible(false)

			
	new_plant.flower_pot = flower_pot
	# 植物初始化，对状态赋值
	new_plant.init_plant_garden(curr_plant_cell_data, curr_garden_bg_type, curr_bg_page, curr_plant_condition)

	
	### 如果植物是陆地植物
	if curr_plant_condition & 2:
		flower_pot.is_water = false
	else:
		flower_pot.is_water = true
		plant_up_position = Vector2(0, 8)

	if not is_last_flower_pot:
		
		plant_postion_node_ori_global_position[Global.PlacePlantInCell.Norm] = plant_container_node[Global.PlacePlantInCell.Norm].global_position
		plant_postion_node_ori_global_position[Global.PlacePlantInCell.Shell] = plant_container_node[Global.PlacePlantInCell.Shell].global_position
		remove_child(plant_container_node[Global.PlacePlantInCell.Norm])
		remove_child(plant_container_node[Global.PlacePlantInCell.Shell])
	
		flower_pot.down_plant_container.add_child(plant_container_node[Global.PlacePlantInCell.Norm])
		flower_pot.down_plant_container.add_child(plant_container_node[Global.PlacePlantInCell.Shell])

		plant_container_node[Global.PlacePlantInCell.Norm].global_position = plant_postion_node_ori_global_position[Global.PlacePlantInCell.Norm] - plant_up_position
		plant_container_node[Global.PlacePlantInCell.Shell].global_position = plant_postion_node_ori_global_position[Global.PlacePlantInCell.Shell] - plant_up_position
		
	plant_container_node[curr_plant_place].add_child(new_plant)

## 在本格使用物品
func use_item_in_this(item:ItemBase):
	
	if plant_in_cell and item is ItemPlantNeedBase:
		var item_plant_need = item as ItemPlantNeedBase
		plant_in_cell.satisfy_need(item_plant_need.plant_need_item)

#region 当前植物格子颜色变化
# 使当前格子发光
func plant_cell_light():
	modulate = Color(2, 2, 2, 1)

# 使当前格子发黑
func plant_cell_dark():
	modulate = Color(0.3, 0.3, 0.3, 1)


func plant_cell_color_restore():
	
	modulate = Color(1, 1, 1, 1)

## 当前格子植物虚影
func plant_cell_shadow():
	is_shadow = true
	modulate = Color(1, 1, 1, 0.6)
	
## 当前格子植物虚影结束
func plant_cell_shadow_end():
	is_shadow = false
	modulate = Color(1, 1, 1, 1)
	
	
	
#endregion

## 获取当前格子植物数据
func get_curr_plant_cell_data():
	if plant_in_cell:
		return plant_in_cell.get_curr_plant_data()
	else:
		return {}


## 获取当前格植物
func get_curr_plant() -> Dictionary:
	if flower_pot and plant_in_cell:
		plant_cell_dark()
		var plant_data :Dictionary = plant_in_cell.get_curr_plant_data()
		return plant_data
	else:
		return {}


func free_curr_plant():
	plant_postion_node_ori_global_position[Global.PlacePlantInCell.Norm] = plant_container_node[Global.PlacePlantInCell.Norm].global_position
	plant_postion_node_ori_global_position[Global.PlacePlantInCell.Shell] = plant_container_node[Global.PlacePlantInCell.Shell].global_position
	
	flower_pot.down_plant_container.remove_child(plant_container_node[Global.PlacePlantInCell.Norm])
	flower_pot.down_plant_container.remove_child(plant_container_node[Global.PlacePlantInCell.Shell])
	add_child(plant_container_node[Global.PlacePlantInCell.Norm])
	add_child(plant_container_node[Global.PlacePlantInCell.Shell])
	
	plant_container_node[Global.PlacePlantInCell.Norm].position = plant_postion_node_ori_position[Global.PlacePlantInCell.Norm]
	plant_container_node[Global.PlacePlantInCell.Shell].position = plant_postion_node_ori_position[Global.PlacePlantInCell.Shell]
	
	flower_pot.queue_free()
	plant_in_cell.queue_free()
	flower_pot = null
	plant_in_cell = null
	


## 激活当前植物生产金币
func activate_curr_plant():
	if plant_in_cell:
		plant_in_cell.activate_plant()
	
## 停止当前植物生产金币
func deactivate_curr_plant():
	if plant_in_cell:
		plant_in_cell.deactivate_plant()
