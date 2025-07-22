extends PlantBase
class_name Caltrop

@export var is_attack:=false
@export var attack_value:=20
@export var zombies_can_attack:Array[ZombieBase] = []
var is_flattened := false

func _on_area_2d_2_area_entered(area: Area2D) -> void:
	var zombie :ZombieBase = area.get_parent()
	if zombie.lane == row_col.x:
		zombies_can_attack.append(zombie)
		is_attack = true


func _on_area_2d_2_area_exited(area: Area2D) -> void:
	var zombie :ZombieBase = area.get_parent()
	if zombie.lane == row_col.x:
		zombies_can_attack.erase(zombie)
		if zombies_can_attack.is_empty():
			is_attack = false


func _attack_once():
	var attack_sound := false
	for zombie:ZombieBase in zombies_can_attack:
		zombie.be_attacked_bullet(attack_value, Global.AttackMode.Real)
		## 保证只触发一次攻击音效
		if not attack_sound:
			attack_sound = true
			SoundManager.play_plant_SFX(Global.PlantType.PeaShooterSingle, "Throw")

## 地刺被压扁
func be_flattened_zomboni(zombie:ZombieBase):
	if not is_flattened:
		is_flattened = true
		if zombie is ZombieZamboni:
			var zombie_zanboni := zombie as ZombieZamboni
			zombie_zanboni.be_caltrop()
		_plant_free()
