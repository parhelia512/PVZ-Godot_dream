extends ComponentBase
class_name MagnetComponent

## 当前持有铁器容器
@export var curr_iron_container: Node2D
@onready var attack_cd_timer: Timer = $AttackCdTimer
@onready var area_2d: Area2D = $Area2D

## 攻击cd(笑话铁器时间)
@export var attack_cd:float = 30

## 当前持有铁器
var curr_iron : Node2D
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
func attack_once(iron_node:IronNodeBase):
	SoundManager.play_plant_SFX(Global.PlantType.P032MagnetShroom, "magnetshroom")

	is_attack_cd = true
	signal_attack_start.emit()

	iron_node.preprocessing_be_magnet()

	## 创建一个新铁器，避免原始铁器动画控制
	var ori_iron_global_position = iron_node.global_position
	var new_iron_node = iron_node.duplicate()
	curr_iron_container.add_child(new_iron_node)
	new_iron_node.global_position = ori_iron_global_position

	new_iron_node.visible = true
	curr_iron = new_iron_node
	var tween = get_tree().create_tween()
	tween.tween_property(new_iron_node, "position", Vector2.ZERO, 0.5)

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
	## 禁用组件\冷却中
	if not is_enabling or is_attack_cd:
		return
	var area_owner = area.owner
	if area_owner is Zombie000Base:
		## 如果没有铁器
		if area_owner.iron_type == Global.IronType.Null:
			return
		else:
			## 僵尸身上的铁器节点
			var iron_node:IronNodeBase = area_owner.iron_node
			if iron_node.is_be_magnet:
				return
			else:
				iron_node.is_be_magnet = true
				attack_once(iron_node)
				## 僵尸调用被删除铁器函数
				area_owner.be_magnet_iron()

	elif area_owner is Ladder:
		## 梯子身上的铁器节点
		var iron_node:IronNodeBase = area_owner.iron_node
		if iron_node.is_be_magnet:
			return
		else:
			iron_node.is_be_magnet = true
		attack_once(iron_node)
		area_owner.ladder_death()


## 角色速度修改
func owner_update_speed(speed_product:float):
	if not attack_cd_timer.is_stopped():
		if speed_product == 0:
			attack_cd_timer.paused = true
		else:
			attack_cd_timer.paused = false

			attack_cd_timer.start(attack_cd_timer.time_left / speed_product)

	attack_cd_timer.wait_time = attack_cd / speed_product
