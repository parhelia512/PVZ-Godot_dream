extends PlantBase
class_name PlantDownBase

## 底部类植物
## 底部植物容器节点，作为中间植物容器的父节点
## 底部植物容器节点会上下移动，带动中间植物上下移动
## 荷叶使用tween控制移动，花盆使用动画控制
## TODO：可以都改为动画类控制
@export var down_plant_container:Node2D
## 底部类植物放置后，norm和shell植物位置变化
@export var plant_up_position :Vector2

## 植物初始化相关
func init_plant(row_col:Vector2i, plant_cell:PlantCell) -> void:
	super.init_plant(row_col, plant_cell)
	plant_cell._flower_pot_change_condition()


# 荷叶死亡切换地形
func _plant_free():
	plant_cell._flower_pot_change_condition()
	plant_free_signal.emit(self)
	
	self.queue_free()


## 代替受伤，同一个格子内，有保护壳，保护壳代替掉血,底部类植物重写
func get_replace_attack_plant():
	if plant_cell.plant_in_cell[Global.PlacePlantInCell.Shell]:
		return plant_cell.plant_in_cell[Global.PlacePlantInCell.Shell]
	elif plant_cell.plant_in_cell[Global.PlacePlantInCell.Norm]:
		return plant_cell.plant_in_cell[Global.PlacePlantInCell.Norm]
	else:
		return null
		
	
