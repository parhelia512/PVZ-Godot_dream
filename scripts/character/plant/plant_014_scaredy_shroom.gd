extends Plant000Base
class_name Plant014ScaredyShroom

@onready var scaredy_component: ScaredyComponent = $ScaredyComponent

@export_group("动画状态")
@export var is_scared := false

@onready var attack_component: AttackComponentBulletBase = $AttackComponent



func init_norm_signal_connect():
	super()
	scaredy_component.signal_scaredy_start.connect(change_is_scared.bind(true))
	scaredy_component.signal_scaredy_end.connect(change_is_scared.bind(false))

	for component:ComponentBase in scaredy_component.scaredy_influence_components:
		scaredy_component.signal_scaredy_start.connect(component.disable_component.bind(ComponentBase.E_IsEnableFactor.Scaredy))
		scaredy_component.signal_scaredy_end.connect(component.enable_component.bind(ComponentBase.E_IsEnableFactor.Scaredy))
	signal_update_speed.connect(attack_component.owner_update_speed)

## 害怕组件信号发射改变植物害怕状态
func change_is_scared(is_scared:bool):
	self.is_scared = is_scared
