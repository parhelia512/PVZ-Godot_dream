extends ResourcePlantCondition
class_name ResourcePlantConditionGraveBuster

## 特殊植物种植函数判断是否可以种植，特殊植物重写,如墓碑吞噬者，咖啡豆等
func judge_special_plants_condition(plant_cell:PlantCell) -> bool:
	## 格子有墓碑就可以种植
	if plant_cell.is_tombstone:
		return true
	else:
		return false
