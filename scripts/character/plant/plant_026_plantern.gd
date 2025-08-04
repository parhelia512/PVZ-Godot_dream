extends PlantBase
class_name Plantern

var fog_node:Fog

@onready var area_2d_2: Area2D = $Area2D2


func _ready() -> void:
	super._ready()
	if fog_node:
		## 要等待一帧后，不然会有偏移，不知道为什么
		await get_tree().process_frame
		fog_node.add_fog_clearer(area_2d_2)


func get_main_game_node():
	curr_scene = get_tree().current_scene
	if curr_scene is MainGameManager:
		if curr_scene.game_para.is_fog:
			fog_node = curr_scene.get_node("Background/Fog")

# 植物死亡
func _plant_free():
	plant_free_signal.emit(self)
	
	if fog_node:
		fog_node.del_fog_clearer(area_2d_2)

	self.queue_free()
	
