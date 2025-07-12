extends BulletLineraBase
class_name BulletPeaSnow

@export var time_be_decelerated :float = 3

func _attack_zombie(zombie:ZombieBase):
	if zombie.armor_second_curr_hp <= 0:
		zombie.be_decelerated(time_be_decelerated)
		super._attack_zombie(zombie)
