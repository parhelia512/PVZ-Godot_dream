extends Node2D
class_name IceRoad

@onready var texture_rect: TextureRect = $TextureRect
## 冰冻生成结束后30秒消失
@export var exist_time:float = 30
var zombie_manager:ZombieManager
## 当前冰道行
var lane :int 
## 当前行植物格子(植物格子顺序为从右向左)
var curr_lane_plant_cells : Array
## 植物格子到达的位置即算覆盖该格子(覆盖格子1/3的位置)
var x_plant_cell_target:Array[float]
## 当前目标格子
var curr_i_plant_cell := 0
## 冰道最左边x值
var left_x = 10000

## 冰道消失信号
signal ice_road_disappear_signal
## 冰道更新信号
signal ice_road_update_signal

func ice_road_init(lane:int, curr_lane_plant_cells:Array, zombie_manager:ZombieManager):
	self.zombie_manager = zombie_manager
	self.lane = lane
	self.curr_lane_plant_cells  = curr_lane_plant_cells 
	for plant_cell:PlantCell in self.curr_lane_plant_cells:
		x_plant_cell_target.append(plant_cell.global_position.x +  plant_cell.size.x*2/3)
		

## 冰冻每次更新, 将冰冻的scale.x设置为-1，右边缘不变，修改大小即可
func expand_size(expand_x:float):
	texture_rect.size.x += expand_x
	left_x = texture_rect.global_position.x - texture_rect.size.x 
	ice_road_update_signal.emit(self)
	
	## 冰道已经覆盖所有植物格子
	if curr_i_plant_cell >= curr_lane_plant_cells.size():
		return
	if left_x < x_plant_cell_target[curr_i_plant_cell]:
		var plant_cell:PlantCell = curr_lane_plant_cells[curr_i_plant_cell]
		plant_cell.add_new_ice_road(self)
		curr_i_plant_cell += 1

	
## 开始计算消失计时器
func start_disappear_timer():
	var timer:Timer = Timer.new()
	add_child(timer)
	timer.name = "IceRoadDisappearTimer"
	timer.one_shot = true
	timer.wait_time = exist_time
	timer.timeout.connect(ice_road_disappear)
	timer.start()
	

func ice_road_disappear():
	for i in range(curr_i_plant_cell):
		var plant_cell:PlantCell = curr_lane_plant_cells[i]
		plant_cell.del_new_ice_road(self)
	zombie_manager.ice_road_list[lane].erase(self)
	ice_road_disappear_signal.emit(self)
	
	queue_free()
	
