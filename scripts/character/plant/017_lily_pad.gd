extends PlantBase
class_name LilyPad

var plant_cell :PlantCell

func _ready() -> void:
	super._ready()
	plant_cell = get_parent()
	plant_cell.lily_pad_change_condition()
	
	
# 荷叶死亡切换地形
func _plant_free():
	
	plant_cell.lily_pad_change_condition()
	plant_free_signal.emit(self)
	
	self.queue_free()


## 代替受伤，同一个格子内，有保护壳，保护壳代替掉血,睡莲重写
## 如果其上方有植物（保护壳-》普通植物 的顺序），代替其掉血
func replace_attack(attack_value:int, zombie:ZombieBase):
	
	var plant_cell:PlantCell = get_parent()
	if plant_cell.plant_in_cell[Global.PlacePlantInCell.Shell]:
		plant_cell.plant_in_cell[Global.PlacePlantInCell.Shell].be_eated(attack_value, zombie)
		return true
	elif plant_cell.plant_in_cell[Global.PlacePlantInCell.Norm]:
		plant_cell.plant_in_cell[Global.PlacePlantInCell.Norm].be_eated(attack_value, zombie)
		return true
	else:
		return false
