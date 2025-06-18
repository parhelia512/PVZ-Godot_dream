extends BulletPea
class_name BulletPeaSnow

@export var time_be_decelerated :float = 3

func _attack_zombie(zombie:ZombieBase):
	super._attack_zombie(zombie)
	zombie.be_decelerated(time_be_decelerated)
