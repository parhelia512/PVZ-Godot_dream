extends PlantBase
class_name HypnoShroom

var is_eated := false
@onready var sleep_shroom: ShroomSleep = $SleepShroom

## 发出音效后消失的植物，需要把音效拎出来
@export var SFX_bomb :AudioStreamPlayer

@export var is_sleep := true


## 子节点SleepShroo会先更新is_sleep
func _ready() -> void:
	super._ready()
	## 植物默认睡眠，根据环境是否为白天判断睡眠状态
	sleep_shroom.judge_sleep()


func stop_sleep():
	is_sleep = false


func be_eated_once(zombie:ZombieBase):
	if not is_eated:
		if zombie.area2d_free:
			return
		
		is_eated = true
		zombie.be_hypnotized()

		## 播放音效
		SoundManager.play_plant_SFX(Global.PlantType.HypnoShroom, &"MindControlled")

		_plant_free()


func keep_idle():
	super.keep_idle()
	sleep_shroom.immediate_hide_zzz()
	stop_sleep()
