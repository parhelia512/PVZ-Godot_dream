extends ZombieNorm
class_name ZombieScreenDoor

## 铁门消失时，隐藏的精灵图
@export var miss_screen_door_fade:Array[Sprite2D]
## 铁门消失时出现的精灵图
@export var miss_screen_door_appear:Array[Sprite2D]
## 有二类防具时 掉手出现的精灵图（有铁门时，被打掉手）
@export var zombie_have_arm_status_2_appear:Array[Sprite2D]
## 没有二类防具时，掉手消失的精灵图（有铁门时，被打掉手）
@export var zombie_have_arm_status_2_fade:Array[Sprite2D]


## 二类防具掉落
func arm2_drop():
	
	super.arm2_drop()	#arm_2_drop.acitvate_it()
	for sprite in miss_screen_door_fade:
		sprite.visible = false
	for sprite in miss_screen_door_appear:
		sprite.visible = true
	
	## 判断是否为掉手状态,若掉手则让下半胳膊消失
	if curr_hp_status >= 2:
		## 隐藏下半胳膊
		for arm_hand_part in zombie_status_2_fade:
			arm_hand_part.visible = false

## 第一次血量2阶段时变化 掉手状态，
func _hp_2_stage():
	#若还有二类防具
	if curr_armor_2_hp_status != 4:
		for sprite in zombie_have_arm_status_2_appear:
			sprite.visible = true
		for sprite in zombie_have_arm_status_2_fade:
			sprite.visible = false
		
	_hand_fade()

	
