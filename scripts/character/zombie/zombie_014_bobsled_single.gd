extends ZombieBase
class_name ZombieBobsledSingle

## 是否为主雪橇
@export var is_main_bobsled := false
## 是否跳上车
@export var is_jump := false
## 是否雪橇车结束下车
@export var is_bobsled_end := false
## 主雪橇僵尸
@export var main_zombie_bobsled :ZombieBobsledSingle

func _ready() -> void:
	super._ready()
	if area2d:
		area2d.collision_layer = 0


## 雪橇车结束
func bobsled_end():
	is_bobsled_end = true
	is_walk = true
	if area2d:
		area2d.collision_layer = 4		#第3层

## 重写受伤函数
func Hp_loss(attack_value:int, bullet_mode : Global.AttackMode = Global.AttackMode.Norm, trigger_be_attack_SFX:=true, no_drop:= false):
	## 如果代替承伤成功
	if replace_attack(attack_value, bullet_mode, trigger_be_attack_SFX, no_drop):
		return
	else:
		super.Hp_loss(attack_value, bullet_mode, trigger_be_attack_SFX, no_drop)


## 代替受伤，若被攻击，还未下车时，非主雪橇僵尸受伤，主雪橇僵尸承伤
func replace_attack(attack_value:int, bullet_mode : Global.AttackMode = Global.AttackMode.Norm, trigger_be_attack_SFX:=true, no_drop:= false):
	## 不是主雪橇僵尸并且还未下车
	if not is_bobsled_end and not is_main_bobsled:
		## 如果存在主雪橇僵尸
		if main_zombie_bobsled:
			main_zombie_bobsled.Hp_loss(attack_value, bullet_mode, trigger_be_attack_SFX, no_drop)
			return true
			
	return false

## 被主僵尸调用跳车
func be_call_jump():
	is_jump = true
	
## 僵尸被炸死	
func be_bomb_death():
	
	## 清空血量
	body.visible = false
	is_bomb_death = true
	is_death = true
	_delete_area2d()
	
	if animation_tree:
		animation_tree.active = false
	
	zombie_charred.visible = true
	# 播放僵尸灰烬动画
	anim_lib.play("ALL_ANIMS")
	await anim_lib.animation_finished
	delete_zombie()
