extends PlantBase
class_name Blover


var fog_node:Fog

func _ready():
	super._ready()
	if not is_idle:
		SoundManager.play_plant_SFX(Global.PlantType.Blover, "blover")
		await get_tree().create_timer(2.0).timeout
		
		_plant_free()


func get_main_game_node():
	curr_scene = get_tree().current_scene
	if curr_scene is MainGameManager:
		if curr_scene.game_para.is_fog:
			fog_node = curr_scene.get_node("Background/Fog")


## 吹散迷雾，动画中调用
func blow_away_fog():
	if fog_node:
		fog_node.be_flow_away()
