extends Node2D
## 组件基类
class_name  ComponentBase


## 是否正在启用
var is_enabling := true
## 默认是否启用组件
@export var is_enable_default := true

## 影响节点是否启用的因素
enum E_IsEnableFactor{
	Defautl,	## 默认是否启用组件,只有角色不使用该组件时在检测器中禁用该组件
	InitType,	## 初始化状态类型（正常、展示、花园）
	Character,	## 角色本身特殊需要禁用组件(确保该条件不会冲突)
	Death,		## 死亡禁用组件
	Prepare,	## 准备（土豆雷）
	Sleep,		## 睡眠
	Scaredy,	## 害怕
	Jump,		## 跳跃
	Hypno,		## 魅惑重启节点
	Attack,		## 攻击(影响眨眼)
	Lose,		## 失去该组件(小丑爆炸匣子)
	Balloon,	## 气球在空中禁用攻击组件
	DownGround,	## 矿工在地下禁用攻击组件
	Garlic,		## 大蒜禁用攻击组件
}

var is_enable_factors:Dictionary[E_IsEnableFactor, bool] = {}

func _ready() -> void:
	if not is_enable_default:
		disable_component(E_IsEnableFactor.Defautl)

## 修改速度
func owner_update_speed(speed_product:float):
	push_error(name, " 必须在子类中重写 owner_update_speed()")

## 改变组件是否启用状态
func change_is_enabling(value:bool, is_enable_factor:E_IsEnableFactor):
	if value:
		enable_component(is_enable_factor)
	else:
		disable_component(is_enable_factor)

## 启用组件
func enable_component(is_enable_factor:E_IsEnableFactor):
	is_enable_factors[is_enable_factor] = true
	is_enabling = is_enable_factors.values().all(func(v): return v == true)

## 禁用组件
func disable_component(is_enable_factor:E_IsEnableFactor):
	is_enable_factors[is_enable_factor] = false
	is_enabling = false

## 被魅惑时组件变化
func owner_be_hypno():
	pass
