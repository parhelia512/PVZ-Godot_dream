extends Zombie000Base
class_name Zombie016Jackbox

@onready var bomb_component_jackbox: BombComponentJackbox = $BombComponentJackbox

@export_group("动画状态")
@export var is_pop:=false

## 初始化正常出战角色信号连接
func init_norm_signal_connect():
	super()
	bomb_component_jackbox.signal_trigger_bomb.connect(_strigger_bomb)
	hp_component.signal_hp_component_death.connect(bomb_component_jackbox.disable_component.bind(ComponentBase.E_IsEnableFactor.Death))

## 触发爆炸
func _strigger_bomb():
	is_pop = true
	SoundManager.play_zombie_SFX(Global.ZombieType.Z016Jackbox, "boing")
	_stop_sfx_enter()

## 失去铁器道具
func loss_iron_item():
	super()
	bomb_component_jackbox.disable_component(ComponentBase.E_IsEnableFactor.Lose)
	_stop_sfx_enter()

func sfx_jack_suprise():
	SoundManager.play_zombie_SFX(Global.ZombieType.Z016Jackbox, "jack_suprise")
