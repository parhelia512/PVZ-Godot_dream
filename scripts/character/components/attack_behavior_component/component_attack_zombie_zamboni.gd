extends AttackComponentBase
class_name AttackComponentZombieZamboni

## 开始攻击
func attack_start():
	attack_ray_component.enemy_can_be_attacked.be_flattened(owner)

## 结束攻击
func attack_end():
	pass
