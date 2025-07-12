extends WallNutBowling
class_name WallNutBowlingBomb

func _launch_bowling():
	## 发射保龄球子弹
	var bullet:BulletLineraBase = bullet_scene.instantiate()
	bullets.add_child(bullet)
	
	bullet.global_position = global_position
	bullet.init_bullet(row_col.x, bullet.global_position)
