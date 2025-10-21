extends Node2D
class_name Ladder

@onready var iron_node: IronNodeCopy = $IronNode

## 梯子所属植物格子
var plant_cell:PlantCell
## 梯子挂载的植物
var plant:Plant000Base
## 梯子所在行
var lane:int

## 初始化梯子
func init_ladder(plant:Plant000Base, plant_cell:PlantCell):
	self.plant = plant
	self.plant_cell = plant_cell
	self.lane = plant_cell.row_col.x
	if is_instance_valid(plant):
		plant.signal_character_death.connect(ladder_death)

## 梯子死亡
func ladder_death():
	queue_free()

func _on_area_2d_area_entered(area: Area2D) -> void:
	var zombie :Zombie000Base = area.owner
	if lane == zombie.lane and not zombie.is_ignore_ladder:
		zombie.start_climbing_ladder()
