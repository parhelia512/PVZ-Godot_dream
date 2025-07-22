extends CherryBomb
class_name DoomShroom


@export var is_sleep := true
@onready var sleep_shroom: ShroomSleep = $SleepShroom


## 播放音效
func play_bome_sfx():
	## 播放音效
	SoundManager.play_plant_SFX(Global.PlantType.DoomShroom, &"DoomShroom")
	


## 子节点SleepShroo会先更新is_sleep
func _ready() -> void:
	super._ready()
	## 植物默认睡眠，根据环境是否为白天判断睡眠状态
	sleep_shroom.judge_sleep()


func stop_sleep():
	is_sleep = false


# 爆炸效果
func _bomb_particle():
	if get_parent() is PlantCell:
		var plantcell:PlantCell = get_parent()
		plantcell.create_crater()
	var panel_doom: Panel_color = get_tree().current_scene.get_node("CanvasLayer_FX/Panel_Doom")
	panel_doom.appear_once()
	
	super._bomb_particle()
	
	
func keep_idle():
	super.keep_idle()
	sleep_shroom.immediate_hide_zzz()
	stop_sleep()

func judge_death_bomb(plant:PlantBase):
	if not is_bomb_end:
		is_bomb_end = true
		if not is_sleep:
			_bomb_all_area_zombie()
