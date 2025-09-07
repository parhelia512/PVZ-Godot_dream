extends BulletBase
class_name BulletWallNutBowlingBig

var rotation_speed = 5.0  # 旋转速度

func _ready() -> void:
	super._ready()
	SoundManager.play_bullet_attack_SFX(SoundManager.TypeBulletSFX.Bowling)
	
func _process(delta: float) -> void:
	super._process(delta)
	bullet_body.rotation += rotation_speed * delta
	

## 子弹击中僵尸
func _on_area_2d_area_entered(area: Area2D) -> void:
	var zombie :ZombieBase = area.owner
	var lane_zombie = zombie.lane
	## 如果僵尸在子弹攻击行
	if bullet_lane == lane_zombie:
		zombie.be_big_bowling_run()
		## 是否有音效
		if type_bullet_SFX != SoundManagerClass.TypeBulletSFX.Null:
			SoundManager.play_bullet_attack_SFX(type_bullet_SFX)
