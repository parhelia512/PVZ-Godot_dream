extends PlantBase
class_name MagnetShroom


@export var is_sleep := true
@onready var sleep_shroom: ShroomSleep = $SleepShroom

## 磁力菇动画参数
@export var is_can_shoot := true
@export var is_shoot := false

@onready var area_2d_2: Area2D = $Area2D2
## 当前持有铁器
var curr_iron : Sprite2D
@onready var curr_iron_positon: Node2D = $CurrIronPositon

## 当前目标铁器种类, 僵尸损失铁器时调用函数参数
var target_iron_type:Global.IronType


#region 蘑菇睡眠相关
#TODO: 重写蘑菇基类
## 子节点SleepShroo会先更新is_sleep
func _ready() -> void:
	super._ready()
	## 植物默认睡眠，根据环境是否为白天判断睡眠状态
	sleep_shroom.judge_sleep()


## 停止睡眠时 对当前区域所有僵尸进行判断攻击
func stop_sleep():
	is_sleep = false
	judge_all_zombie()
	

func keep_idle():
	super.keep_idle()
	sleep_shroom.immediate_hide_zzz()
	stop_sleep()


#endregion

## 对当前区域所有僵尸进行判断攻击
func judge_all_zombie():
	var overlapping = area_2d_2.get_overlapping_areas()
	for area in overlapping:
		var zombie:ZombieBase = area.get_parent()
		if judge_and_shoot_zombie(zombie):
			break

## 判断僵尸是否有铁器，若有，则攻击
func judge_and_shoot_zombie(zombie:ZombieBase) -> bool:
	## 如果僵尸有铁器防具，并且当前防具未被打破（即当前防具精灵节点未隐藏）
	## 一类防具
	if zombie.is_iron_armor_1 and zombie.armor_1_sprite2d.visible:
		target_iron_type = Global.IronType.IronArmor1
		removes_iron(zombie, zombie.armor_1_sprite2d)
		return true
		
	## 二类防具
	if zombie.is_iron_armor_2 and zombie.armor_2_sprite2d.visible:
		target_iron_type = Global.IronType.IronArmor2
		removes_iron(zombie, zombie.armor_2_sprite2d)
		return true
		
	## 道具
	if zombie.is_iron_item and zombie.iron_item_sprite.visible:
		target_iron_type = Global.IronType.IronItem
		removes_iron(zombie, zombie.iron_item_sprite)
		return true
		
	return false


## 碰撞区域检测到僵尸，并且当前可以shoot时
func _on_area_2d_2_area_entered(area: Area2D) -> void:
	## 当前未睡眠并且可以磁力
	if not is_sleep and is_can_shoot:
		judge_all_zombie()


## 磁力菇吸铁
func removes_iron(zombie:ZombieBase,iron_sprite:Sprite2D):
	is_can_shoot = false
	is_shoot = true
	
	## 僵尸调用被删除铁器函数
	zombie.be_remove_iron(target_iron_type)
	iron_sprite.visible = false
	var ori_iron_global_position = iron_sprite.global_position
	
	## 创建一个新铁器，避免原始铁器动画控制
	var new_iron_sprite = iron_sprite.duplicate()
	new_iron_sprite.visible = true
	add_child(new_iron_sprite)
	new_iron_sprite.global_position = ori_iron_global_position
	curr_iron = new_iron_sprite
	var tween = get_tree().create_tween()
	tween.tween_property(new_iron_sprite, "position", curr_iron_positon.position, 0.5)
	## 消化15秒
	await get_tree().create_timer(15.0).timeout
	
	is_shoot = false
	is_can_shoot = true
	curr_iron.queue_free()
	## 消化完成后，判断当前区域是否有铁器僵尸
	judge_all_zombie()
