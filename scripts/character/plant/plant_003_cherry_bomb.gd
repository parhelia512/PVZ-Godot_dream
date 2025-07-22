extends PlantBase
class_name CherryBomb

@export var is_bomb := true
@onready var bomb_effect = $BombEffect

## 爆炸检测碰撞体
@onready var area_2d_2: Area2D = $Area2D2
## 已经爆炸过，植物死亡检测是否爆炸过，若没有，则爆炸
var is_bomb_end:= false

func _ready() -> void:
	super._ready()
	
	plant_free_signal.connect(judge_death_bomb)

## 播放音效
func play_bome_sfx():
	## 播放音效
	SoundManager.play_plant_SFX(Global.PlantType.CherryBomb, &"CherryBomb")
	

# 爆炸效果
func _bomb_particle():
	play_bome_sfx()
	child_node_change_parent(bomb_effect, bombs)
	bomb_effect.activate_bomb_effect()
	_plant_free()
	
func judge_death_bomb(plant:PlantBase):
	if not is_bomb_end:
		is_bomb_end = true
		_bomb_all_area_zombie()


func _bomb_all_area_zombie():
	if not is_bomb_end:
		is_bomb_end = true
		var areas = area_2d_2.get_overlapping_areas()
		for area in areas:
			area.get_parent().be_bomb_death()
		
		_bomb_particle()
	
