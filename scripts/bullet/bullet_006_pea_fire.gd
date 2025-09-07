extends BulletLinear000Base
class_name Bullet006PeaFire

@onready var area_2d_spatter: Area2D = $Area2DSpatter
@onready var anim_lib: AnimationPlayer = $Body/AnimLib

func _ready() -> void:
	super()
	anim_lib.play(&"ALL_ANIMS")

## 攻击一次
func attack_once(enemy:Character000Base):
	super(enemy)
	enemy.cancel_ice()
	_spatter_all_area_zombie(enemy)

## 溅射伤害
func _spatter_all_area_zombie(direct_hit_enemy:Character000Base):
	var areas = area_2d_spatter.get_overlapping_areas()
	var all_splatter_enemy = []
	for area in areas:
		var enemy:Character000Base = area.owner
		if direct_hit_enemy == enemy:
			continue
		else:
			all_splatter_enemy.append(enemy)
	if all_splatter_enemy.is_empty():
		return
	else:
		var damage_per_enemy: int = clampi(40 / all_splatter_enemy.size(), 1, 13)
		for enemy:Character000Base in all_splatter_enemy:
			enemy.be_attacked_bullet(damage_per_enemy, Global.AttackMode.Penetration, false)

