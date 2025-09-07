extends ComponentBase
class_name MagnetComponent

## 当前持有铁器容器
@onready var curr_iron_container: Node2D = $CurrIronContainer
@onready var attack_cd_timer: Timer = $AttackCdTimer
@onready var area_2d: Area2D = $Area2D

## 攻击cd(笑话铁器时间)
@export var attack_cd:float = 5
## 当前持有铁器
var curr_iron : Sprite2D
## 是否已攻击
var is_attack_cd:=false

## 开始攻击
signal signal_attack_start
## 攻击完毕(冷却完成)
signal signal_attack_cd_end

func _ready() -> void:
	super()
	attack_cd_timer.wait_time = attack_cd


## 启用组件
func enable_component(is_enable_factor:E_IsEnableFactor):
	super(is_enable_factor)
	if is_enabling:
		for area in area_2d.get_overlapping_areas():
			_on_area_2d_area_entered(area)


## 磁力菇吸铁
func attack_once(zombie:Zombie000Base):
	if not is_attack_cd:
		is_attack_cd = true
		signal_attack_start.emit()

		## 僵尸身上的铁器节点
		var iron_node :Node2D = zombie.iron_node
		## 创建一个新铁器，避免原始铁器动画控制
		var ori_iron_global_position = iron_node.global_position
		var new_iron_sprite = iron_node.duplicate()
		new_iron_sprite.visible = true
		curr_iron_container.add_child(new_iron_sprite)
		new_iron_sprite.global_position = ori_iron_global_position
		curr_iron = new_iron_sprite
		var tween = get_tree().create_tween()
		tween.tween_property(new_iron_sprite, "position", curr_iron_container.position, 0.5)

		## 僵尸调用被删除铁器函数
		zombie.be_remove_iron()
		iron_node.visible = false

		attack_cd_timer.start()

## 消化铁器完成
func _on_attack_cd_timer_timeout() -> void:
	signal_attack_cd_end.emit()
	is_attack_cd = false
	curr_iron.queue_free()
	for area in area_2d.get_overlapping_areas():
		_on_area_2d_area_entered(area)

## 有僵尸进入到吸铁范围内
func _on_area_2d_area_entered(area: Area2D) -> void:
	if not is_enabling:
		return

	var zombie:Zombie000Base = area.owner
	## 如果没有铁器\正在攻击(冷却)中
	if zombie.iron_type == Global.IronType.Null or is_attack_cd:
		return
	attack_once(zombie)
