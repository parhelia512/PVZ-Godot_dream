extends Control
class_name PlantCell

signal click_cell
signal cell_mouse_enter
signal cell_mouse_exit

signal cell_delete_tombstone	## 删除墓碑信号

@onready var button: Button = $Button
## 植物种植位置
@onready var plant_position: Control = $PlantPosition
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
@export var is_ice_tunnel := false:
	get:
		return is_ice_tunnel
	set(v):
		is_ice_tunnel = v
		_update_state()

## 当前cell的墓碑
var tombstone:TombStone
## 当前cell的坑洞
var crater:DoomShroomCrater
## 毁灭菇坑洞场景
const doom_shroom_scenes:PackedScene =  preload("res://scenes/fx/doom_shroom_crater.tscn")
## 水池移动所需的tween
var tween: Tween

func _ready() -> void:
	## 隐藏按钮样式
	var new_stylebox_normal = $Button.get_theme_stylebox("pressed").duplicate()
	$Button.add_theme_stylebox_override("normal", new_stylebox_normal)
	
	## 根据格子类型初始化植物种植地形条件
	init_condition()
	

func _process(delta: float) -> void:
	## 如果水池有植物，跟随位置缓慢移动
	if tween:
		if plant_in_cell[Global.PlacePlantInCell.Down]:
			plant_in_cell[Global.PlacePlantInCell.Down].global_position = plant_position.global_position
		if plant_in_cell[Global.PlacePlantInCell.Norm]:
			plant_in_cell[Global.PlacePlantInCell.Norm].global_position = plant_position.global_position - Vector2(0, 20)
		if plant_in_cell[Global.PlacePlantInCell.Shell]:
			plant_in_cell[Global.PlacePlantInCell.Shell].global_position = plant_position.global_position - Vector2(0, 20)

## 新植物种植
func new_plant(plant:PlantBase):
	plant_in_cell[plant.plant_condition.place_plant_in_cell] = plant
	plant.global_position = plant_position.global_position

	
	plant.init_plant(row_col)
	
	## 如果下面有植物，提高中间植物和壳的位置
	if plant_in_cell[Global.PlacePlantInCell.Down]:
		if plant_in_cell[Global.PlacePlantInCell.Norm]:
			plant_in_cell[Global.PlacePlantInCell.Norm].global_position = plant_position.global_position - Vector2(0, 20)
		if plant_in_cell[Global.PlacePlantInCell.Shell]:
			plant_in_cell[Global.PlacePlantInCell.Shell].global_position = plant_position.global_position - Vector2(0, 20)

## 获取种植新植物时植物虚影的位置
func get_new_plant_static_shadow_global_position(place_plant_in_cell:Global.PlacePlantInCell):
	## 如果下面有植物，提高中间植物和壳的位置
	if plant_in_cell[Global.PlacePlantInCell.Down]:
		if place_plant_in_cell == Global.PlacePlantInCell.Norm or place_plant_in_cell == Global.PlacePlantInCell.Shell:
			return plant_position.global_position - Vector2(0, 20)
	return plant_position.global_position

## 植物死亡
func one_plant_free(plant:PlantBase):
	plant_in_cell[plant.plant_condition.place_plant_in_cell] = null
	##如果植物死亡时鼠标在当前植物格子中，重新发射鼠标进入格子信号检测种植
	if is_mouse_in_ui(button):
		_on_button_mouse_entered()

# 根据当前格子类型初始化当前格子状态
func init_condition():
	match plant_cell_type:
		PlantCellType.Grass:
			curr_condition = 3
		## 如果是水池，让其植物位置上下缓慢移动
		PlantCellType.Pool:
			curr_condition = 9
			start_movement()
			
		PlantCellType.Roof:
			curr_condition = 33

## 如果是水池地形，使其位置上下缓慢移动
func start_movement():
	tween = create_tween()
	tween.set_loops()  # 无限循环
	tween.set_trans(Tween.TRANS_SINE)  # 平滑缓动

	# 向上移动
	tween.tween_property(
		plant_position, 
		"position:y", 
		plant_position.position.y - 5, 
		2 + randf()
	).set_ease(Tween.EASE_IN_OUT)

	# 向上移动（返回原点）
	tween.tween_property(
		plant_position, 
		"position:y", 
		plant_position.position.y , 
		2 + randf()
	).set_ease(Tween.EASE_IN_OUT)

## 更新状态
func _update_state():
	# 先判断特殊状态(有墓碑、坑洞或冰道)
	if is_tombstone or is_crater or is_ice_tunnel:
		can_common_plant = false
	else:
		can_common_plant = true
	
## 荷叶种植死亡时调用
func lily_pad_change_condition():
	## 切换荷叶地形
	curr_condition = curr_condition ^ 16
	## 切换水池地形
	curr_condition = curr_condition ^ 8
	
	
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

func return_plant_be_shovel_look():
	if plant_in_cell[Global.PlacePlantInCell.Norm]:
		return  plant_in_cell[Global.PlacePlantInCell.Norm]
	elif plant_in_cell[Global.PlacePlantInCell.Down]:
		
		return  plant_in_cell[Global.PlacePlantInCell.Down]
	else:
		return null
		

#endregion
