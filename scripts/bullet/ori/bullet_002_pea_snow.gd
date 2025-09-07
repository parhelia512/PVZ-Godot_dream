extends BulletBase
class_name BulletPeaSnow

@export var time_be_decelerated :float = 3.0

func _attack_zombie(zombie:Zombie000Base):
	if zombie.hp_component.curr_hp_stage_armor1 <= 0:
		zombie.be_ice_decelerate(time_be_decelerated)
	super._attack_zombie(zombie)
