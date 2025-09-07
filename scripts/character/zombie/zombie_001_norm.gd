extends Zombie000Base
class_name Zombie001Norm

## 里面的手拿东西
@export var is_inner_hand_zombie := false
@export_group("动画状态")
## 动画状态（僵尸有某类动画有多种）
@export var idle_status := 1
@export var walk_status := 1
@export var death_status := 1

@export_subgroup("最大动画状态")
@export var idle_status_max := 2
@export var walk_status_max := 2
@export var death_status_max := 2

@export_group("普僵初始化精灵节点")
@export var init_sprite_random:Array[Sprite2D]


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	super()
	_random_anim_status()
	_random_sprit_appear()


@onready var anim_innerarm : Array[Sprite2D] = [
	$Body/BodyCorrect/Anim_innerarm3,
	$Body/BodyCorrect/Anim_innerarm2,
	$Body/BodyCorrect/Anim_innerarm1
	]
@onready var flag_hand_and_arm : Array[Sprite2D]  = [
	$Body/BodyCorrect/Zombie_flaghand,
	$Body/BodyCorrect/Zombie_innerarm_screendoor,
	$Body/BodyCorrect/Zombie_innerarm_screendoor_hand
	]


# 切换到死亡动画时修改flaghand
func _death_anim():
	if is_inner_hand_zombie:
		for arm in anim_innerarm:
			arm.visible = true
		for flag_hand_or_arm in flag_hand_and_arm:
			flag_hand_or_arm.visible = false



## 随机选择动画状态种类
func _random_anim_status():
	idle_status = randi_range(1, idle_status_max)
	walk_status = randi_range(1, walk_status_max)
	death_status = randi_range(1, death_status_max)

func _random_sprit_appear():
	for sprite in init_sprite_random:
		sprite.visible = [true, false].pick_random()

