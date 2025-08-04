extends Node2D
class_name ShroomSleepGarden

## 用于管理蘑菇睡觉
@onready var animation_player: AnimationPlayer = $AnimationPlayer


func judge_sleep():
	var plant_shroom_garden:PlantShroomGarden = get_parent()
	if get_tree().current_scene is GardenManager:
		## 睡眠
		if plant_shroom_garden.curr_garden_bg != GardenManager.GardenBgType.GreenHouse:
			plant_shroom_garden.stop_sleep()
			animation_player.stop()
			visible = false
			
		
		else:
			plant_shroom_garden.start_sleep()
			animation_player.play("zzz")
			visible = true
			scale = Vector2(1,1)/get_parent().scale
