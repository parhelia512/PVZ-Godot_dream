extends Resource
class_name ResourcePlantCondition

@export_group("植物种植")
@export_flags("1 无", "2 草地", "4 花盆", "8 水", "16 睡莲", "32 屋顶/裸地") 
## 植物种植地形条件（满足一个即可），默认（草地2+花盆4+睡莲16 = 22）
var plant_condition:int = 22

## 植物在格子中占的位置，
@export var place_plant_in_cell :Global.PlacePlantInCell = Global.PlacePlantInCell.Norm

## 是否为特殊植物，非特殊植物满足上面两点（地形条件、格子位置）种植即可, 
## 特殊植物调用重写方法判断是否可以种植judge_special_plants_condition
@export var is_special_plants := false


## 特殊植物种植函数判断是否可以种植，特殊植物重写,如墓碑吞噬者，咖啡豆等
func judge_special_plants_condition(plent_cell:PlantCell) -> bool:
	return true
