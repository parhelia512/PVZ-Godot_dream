extends PeaShooterSingle
class_name StarFruit


@export var ray_cast_2d_list: Array[RayCast2D]
@export var bullet_position_list :Array[Node2D]

func judge_ray_zomebie():
	for ray_cast_2d in ray_cast_2d_list:
		if ray_cast_2d.is_colliding():
			return true
	return false



func _shoot_bullet():
	for i:int in range(ray_cast_2d_list.size()):
		var bullet:BulletBase = bullet_scene.instantiate()
		bullet.global_position = bullet_position_list[i].global_position
		bullets.add_child(bullet)
		bullet.init_bullet(row_col.x, bullet.global_position, Vector2.RIGHT.rotated(ray_cast_2d_list[i].rotation))
	play_throw_sfx()
