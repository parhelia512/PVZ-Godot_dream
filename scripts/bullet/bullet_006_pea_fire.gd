extends BulletBase
class_name BulletPeaFire

@onready var anim_lib: AnimationPlayer = $AnimLib
## 溅射伤害碰撞器
@onready var area_2d_3: Area2D = $Area2D3

func _ready() -> void:
	super._ready()
	anim_lib.play("ALL_ANIMS")



## 攻击一次僵尸
func _attack_zombie(zombie:ZombieBase):
	## 取消其减速
	zombie._on_timer_timeout_time_decelerate()
	
	super._attack_zombie(zombie)
	_spatter_all_area_zombie(zombie)
	## 是否有音效
	if type_bullet_SFX != SoundManagerClass.TypeBulletSFX.Null:
		SoundManager.play_bullet_attack_SFX(type_bullet_SFX)
	if bullet_effect:
		bullet_effect_change_parent(bullet_effect)
		bullet_effect.activate_bullet_effect()
	queue_free()


## 溅射伤害
func _spatter_all_area_zombie(direct_hit_zombie:ZombieBase):
	var areas = area_2d_3.get_overlapping_areas()
	var splatter_zombies = []
	for area in areas:
		var zombie:ZombieBase = area.get_parent()
		if direct_hit_zombie == zombie:
			continue
		else:
			splatter_zombies.append(zombie)
	if splatter_zombies.is_empty():
		return
	else:
		var damage_per_zombie: int = clampi(40 / splatter_zombies.size(), 1, 13)
		for zombie:ZombieBase in splatter_zombies:
			zombie.be_attacked_bullet(damage_per_zombie, Global.AttackMode.Penetration, false)
	
