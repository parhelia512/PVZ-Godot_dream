extends PlantBase
class_name Jalapeno


@onready var fire: Fire = $Fire
@export var is_bomb := true
var is_bomb_end := false



func _ready() -> void:
	super._ready()
	
	plant_free_signal.connect(judge_death_bomb)

func judge_death_bomb(plant:PlantBase):
	if not is_bomb_end:
		is_bomb_end = true
		_bomb_fire()

func _bomb_fire():
	is_bomb_end = true
	var main_game:MainGameManager = get_tree().current_scene
	var zombie_manager :ZombieManager = main_game.zombie_manager
	var hand_manager :HandManager = main_game.hand_manager
	
			
	## 播放音效
	SoundManager.play_plant_SFX(Global.PlantType.Jalapeno, &"Jalapeno")
	
	#
	for i in range(zombie_manager.zombies_all_list[row_col.x].size()-1, -1, -1) :
		zombie_manager.zombies_all_list[row_col.x][i].be_bomb_death()
	

	fire.visible = true
	for plant_cell:PlantCell in hand_manager.plant_cells_array[row_col.x]:
		var fire_new:Fire = fire.duplicate()
		## 修改其图层
		fire_new.z_index = 415 + row_col.x * 10
		fire_new.z_as_relative = false
		
		plant_cell.add_child(fire_new)
		fire_new.global_position = plant_cell.plant_cell_down.global_position
		fire_new.activate_bomb_effect()

	## 等待一帧后，删除冰道，与雪橇车小队交互需要
	await get_tree().process_frame
	for i in range(zombie_manager.ice_road_list[row_col.x].size() - 1, -1, -1):
		var ice_road = zombie_manager.ice_road_list[row_col.x][i]
		if is_instance_valid(ice_road):
			## 使用冰冻类的消失方法，更新对应的plantcell的状态
			ice_road.ice_road_disappear()
			
	_plant_free()
