extends PlantBase
class_name PeaShooterSingle

@export var is_attack := false

@onready var ray_cast_2d: RayCast2D = $RayCast2D

@export var bullet_pea_scene : PackedScene
@onready var bullet_position = $Body/Anim_stem/stem_correct/Projectile


func _process(delta):

	# 每帧检查射线是否碰到僵尸
	if ray_cast_2d.is_colliding():
		if not is_attack:
			is_attack = true
		
	else:
		if is_attack:
			is_attack = false
	
func _shoot_bullet():
	var bullet = bullet_pea_scene.instantiate()
	
	bullets.add_child(bullet)
	bullet.global_position = bullet_position.global_position
	# SFX 豌豆射手发射豌豆
	get_node("Throw" + str(randi_range(1, 2))).play()
