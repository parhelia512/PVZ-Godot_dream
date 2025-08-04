extends BulletBase
class_name BulletWallNutBowlingBomb

var rotation_speed = 5.0  # 旋转速度
@onready var area_2d_2: Area2D = $Area2D2

func _ready() -> void:
	super._ready()
	SoundManager.play_bullet_attack_SFX(SoundManager.TypeBulletSFX.Bowling)
	

func _process(delta: float) -> void:
	super._process(delta)
	bullet_body.rotation += rotation_speed * delta
	

## 子弹击中僵尸
func _on_area_2d_area_entered(area: Area2D) -> void:
	##等待一帧，不然直接爆炸会没有伤害
	await get_tree().process_frame
	var zombie :ZombieBase = area.get_parent()
	var lane_zombie = zombie.lane
	## 如果僵尸在子弹攻击行
	if bullet_lane == lane_zombie:
		if not is_attack:
			is_attack = true
			## 爆炸炸死所有僵尸
			_bomb_all_area_zombie()
			queue_free()


# 爆炸效果
func _bomb_particle():
	SoundManager.play_plant_SFX(Global.PlantType.CherryBomb, &"CherryBomb")
	
	bullet_effect_change_parent(bullet_effect)
	bullet_effect.activate_bomb_effect()

func _bomb_all_area_zombie():
	var areas = area_2d_2.get_overlapping_areas()
	for area in areas:
		area.get_parent().be_bomb_death()
	
	_bomb_particle()
	
