extends Plant000Base
class_name Plant015IceShroom

@onready var bomb_component: BombComponentBase = $BombComponent

func init_norm_signal_connect():
	super()
	## 角色死亡信号连接
	hp_component.signal_hp_component_death.connect(bomb_component.judge_death_bomb)
