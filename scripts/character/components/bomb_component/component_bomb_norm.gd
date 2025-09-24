extends BombComponentBase
class_name BombComponentNorm
## 普通炸弹使用爆炸组件

@onready var bomb_effect: BombEffectBase = $BombEffect

## 爆炸特效
func _start_bomb_fx():
	bomb_effect.activate_bomb_effect()

## 炸死所有敌人
func _bomb_all_enemy():
	var areas = area_2d_bomb.get_overlapping_areas()
	for area in areas:
		var character:Character000Base = area.owner
		if character is Plant000Base:
			var plant:Plant000Base = character as Plant000Base
			if plant.curr_be_attack_status & can_attack_plant_status:
				plant.be_bomb(bomb_value, is_cherry_bomb)
		if character is Zombie000Base:
			var zombie:Zombie000Base = character as Zombie000Base
			if zombie.curr_be_attack_status & can_attack_zombie_status:
				zombie.be_bomb(bomb_value, is_cherry_bomb)
