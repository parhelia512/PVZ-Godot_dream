extends PlantBase
class_name WallNutBowling

@export var bullet_scene : PackedScene
func _ready() -> void:
	## 等待一帧位置修改
	await get_tree().process_frame
	get_main_game_node()
	_launch_bowling()
	_plant_free()

func _launch_bowling():
	## 发射保龄球子弹
	var bullet:BulletBase = bullet_scene.instantiate()
	bullets.add_child(bullet)
		
	bullet.global_position = global_position
	bullet.init_bullet(row_col.x, bullet.global_position)
	
	bullet.update_z_index_and_lane(-1, row_col.x)
