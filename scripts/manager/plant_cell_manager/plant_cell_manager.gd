extends Node
class_name PlantCellManager

@onready var plant_cells_root: Node2D = %PlantCellsRoot
@onready var tomb_stone_manager: TombStoneManager = $TombStoneManager


func _ready() -> void:
	## 火爆辣椒爆炸特效和冰道
	EventBus.subscribe("jalapeno_bomb_effect_and_ice_road", jalapeno_bomb_effect_and_ice_road)
	MainGameDate.all_plant_cells.clear()
	# 植物种植区域信号，更新植物位置列号,更新墓碑信息
	for plant_cells_row_i in plant_cells_root.get_child_count():
		## 某一行all_plant_cells
		var plant_cells_row = plant_cells_root.get_child(plant_cells_row_i)
		var plant_cells_row_node := []
		## plant_cell是从右向左的顺序，这里从左到右
		for plant_cells_col_j in range(plant_cells_row.get_child_count() - 1, -1, -1):
			var plant_cell:PlantCell = plant_cells_row.get_child(plant_cells_col_j)
			plant_cell.row_col = Vector2(plant_cells_row_i, plant_cells_col_j)
			plant_cells_row_node.append(plant_cell)
		MainGameDate.all_plant_cells.append(plant_cells_row_node)

	MainGameDate.row_col = Vector2i(MainGameDate.all_plant_cells.size(), MainGameDate.all_plant_cells[0].size())


func init_plant_cell_manager(game_para:ResourceLevelData):
	tomb_stone_manager.init_tomb_stone_manager(game_para)

func create_tombstone(new_num:int):
	tomb_stone_manager.create_tombstone(new_num)

## 火爆辣椒爆炸特效
## [lane:int]:行
func jalapeno_bomb_effect_and_ice_road(lane:int):
	for plant_cell:PlantCell in MainGameDate.all_plant_cells[lane]:
		var fire_new:BombEffectFire = SceneRegistry.FIRE.instantiate()
		## 修改其图层
		fire_new.z_index = 400 + (lane + 1) * 10 + 5
		fire_new.z_as_relative = false

		plant_cell.add_child(fire_new)
		fire_new.global_position = plant_cell.global_position + Vector2(plant_cell.size.x / 2, plant_cell.size.y)
		fire_new.activate_bomb_effect()

	for i in range(MainGameDate.all_ice_roads[lane].size()-1, -1, -1):
		var ice_road:IceRoad = MainGameDate.all_ice_roads[lane][i]
		ice_road.ice_road_disappear()
