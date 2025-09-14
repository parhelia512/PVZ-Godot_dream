extends ZombieNorm
class_name ZombieFlag


@export var zombie_flag2 : Texture2D

@onready var anim_innerarm : Array[Sprite2D] = [$Body/Anim_innerarm3, $Body/Anim_innerarm2, $Body/Anim_innerarm1]
@onready var flag_hand_and_arm : Array[Sprite2D]  = [$Body/Zombie_flaghand, $Body/Zombie_innerarm_screendoor]


# 切换到死亡动画时修改flaghand
func _death_anim():
	for arm in anim_innerarm:
		arm.visible = true
	for flag_hand_or_arm in flag_hand_and_arm:
		flag_hand_or_arm.visible = false
		
func _hp_2_stage():
	_hand_fade()
	$Body/Zombie_flaghand.texture = zombie_flag2

# 随机生成状态
func _rand_anim_status():
	idle_status = 1
	walk_status = 1
	death_status = 1
