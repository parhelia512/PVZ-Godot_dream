extends ComponentBase
## 基础攻击组件，攻击组件都有攻击射线检测组件（attack_ray_component）
class_name AttackComponentBase

@onready var attack_ray_component: AttackRayComponent = $AttackRayComponent

## 是否正在攻击
var is_attack := false

signal signal_change_is_attack(value:bool)

func _ready() -> void:
	attack_ray_component.signal_can_attack.connect(attack_start)
	attack_ray_component.signal_not_can_attack.connect(attack_end)


## 启用组件
func enable_component(is_enable_factor:E_IsEnableFactor):
	super(is_enable_factor)
	attack_ray_component.enable_component(is_enable_factor)


## 禁用组件
func disable_component(is_enable_factor:E_IsEnableFactor):
	super(is_enable_factor)
	attack_ray_component.disable_component(is_enable_factor)

## 开始攻击
func attack_start():
	if not is_enabling:
		return
	if is_attack:
		return
	else:
		is_attack = true
		signal_change_is_attack.emit(true)

## 结束攻击
func attack_end():
	is_attack = false
	signal_change_is_attack.emit(false)

## 被魅惑
func owner_be_hypno():
	attack_ray_component.owner_be_hypno()
