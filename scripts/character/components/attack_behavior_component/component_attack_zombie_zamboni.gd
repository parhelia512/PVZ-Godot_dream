extends AttackComponentBase
class_name AttackComponentZombieZamboni

## 开始攻击
func attack_start():
	for character:Character000Base in attack_ray_component.enemies_can_be_attacked:
		character.be_flattened(owner)

## 结束攻击
func attack_end():
	pass
