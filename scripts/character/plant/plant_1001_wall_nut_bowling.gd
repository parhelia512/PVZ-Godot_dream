extends Plant000Base
class_name Plant1001WallNutBowling

@export var bowling_bullet_scene:PackedScene
var bullets:Node2D

## 初始化正常出战角色
func init_norm():
	bullets = MainGameDate.bullets
	_launch_bowling()
	queue_free()


func _launch_bowling():
	## 发射保龄球子弹
	var bullet:Bullet000Base = bowling_bullet_scene.instantiate()
	bullet.init_bullet(row_col.x, bullets.to_local(global_position))
	bullets.add_child(bullet)
