extends BombComponentBase
class_name BombComponentJackbox
## 小丑爆炸组件
## 小丑爆炸攻击所有范围内敌人

@onready var jack_bomb_timer: Timer = $JackBombTimer
@onready var bomb_effect: BombEffectBase = $BombEffect


## 早爆小丑概率
@export_range(0, 100, 1) var probability_early_bomb :int = 5
## 早爆小丑时间范围
@export var early_time_range:Vector2 = Vector2(4.4, 7.45)
## 晚爆小丑时间范围
@export var late_time_range:Vector2 = Vector2(13.22, 22.68)
## 小丑出生后爆炸时间
var wait_time_bomb :float= 0.0

## 小丑触发爆炸信号
signal signal_trigger_bomb

func _ready() -> void:
	owner = owner as Zombie000Base
	## 如果出战角色
	if owner.character_init_type == Character000Base.E_CharacterInitType.IsNorm:
		var p = randi_range(1,100)
		## 早爆小丑
		if p <= probability_early_bomb:
			wait_time_bomb = randf_range(early_time_range.x, early_time_range.y)
		else:
			wait_time_bomb = randf_range(late_time_range.x, late_time_range.y)
		jack_bomb_timer.start(wait_time_bomb)

## 角色速度修改
func owner_update_speed(speed_product:float):
	if not jack_bomb_timer.is_stopped():
		if speed_product == 0:
			jack_bomb_timer.paused = true
		else:
			jack_bomb_timer.paused = false

			jack_bomb_timer.start(jack_bomb_timer.time_left / speed_product)

## 爆炸时间到,发射触发爆炸信号
func _on_jack_bomb_timer_timeout() -> void:
	signal_trigger_bomb.emit()

## 爆炸特效
func _start_bomb_fx():
	bomb_effect.activate_bomb_effect()

## 炸死所有敌人
func _bomb_all_enemy():
	var areas = area_2d_bomb.get_overlapping_areas()
	for area in areas:
		var character:Character000Base = area.owner
		## 角色死亡直接消失
		character.character_death_disappear()

## 禁用组件
func disable_component(is_enable_factor:E_IsEnableFactor):
	is_enable_factors[is_enable_factor] = false
	is_enabling = false
	jack_bomb_timer.stop()
