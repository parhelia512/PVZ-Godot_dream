extends AttackComponentBulletPultBase
class_name AttackComponentBulletCorn
## 玉米投手攻击行为组件

## 投射黄油的概率
@export_range(0,1,0.01) var p_butter:float = 0.5
## body中的黄油节点
@export var sprite_2d_butter_in_body:Sprite2D

func _on_bullet_attack_cd_timer_timeout() -> void:
	super()
	var p = randf()
	if p < p_butter:
		attack_bullet_type = Global.BulletType.Bullet011Butter
		sprite_2d_butter_in_body.visible = true
	else:
		attack_bullet_type = Global.BulletType.Bullet010Corn


func _shoot_bullet():
	super()
	sprite_2d_butter_in_body.visible = false
