extends Plant000Base
class_name Plant013HypnoShroom


## 被僵尸啃食一次
func be_zombie_eat_once(attack_zombie:Zombie000Base):
	if curr_replace_be_attack_plant:
		curr_replace_be_attack_plant.be_zombie_eat_once(attack_zombie)
		return
	body.body_light()
	hypno_zombie(attack_zombie)

## 魅惑僵尸
func hypno_zombie(zombie:Zombie000Base):
	if not is_sleeping:
		SoundManager.play_plant_SFX(Global.PlantType.HypnoShroom, "MindControlled")
		zombie.be_hypno()
		character_death()

