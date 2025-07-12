extends PeaShooterSingle
class_name ThreePeater

@export var ray_cast_2d_list: Array[RayCast2D]
@export var blink_sprite_list: Array[Sprite2D]	## 控制idle状态下植物眨眼

## 边路补偿(0：正常，1：上路补偿，-1：下路补偿)
@export var bullet_border_compensation := 0


func init_plant(row_col:Vector2i) -> void:
	super.init_plant(row_col)
	_judge_position_bullet_position()


func _on_blink_timer_timeout():
	## is_blink状态下眨眼
	if is_blink:
		for blink_sprite in blink_sprite_list:
			do_blink(blink_sprite)


func judge_ray_zomebie():
	for ray in ray_cast_2d_list:
		if ray.is_colliding():
			return true
	
	return false

	
func _shoot_bullet():
	for i in range(3):
		## 边路补偿补偿
		print((bullet_border_compensation == 1 and i == 0) or (bullet_border_compensation == -1 and i == 2))
		if (bullet_border_compensation == 1 and i == 0) or (bullet_border_compensation == -1 and i == 2):
			_create_bullte(0.3, 1)
			
		else:
			_create_bullte(0, i, true)
		
	## 攻击音效
	if throw_SFX.size() > 0:
		throw_SFX[randi() % throw_SFX.size()].play()

func _create_bullte(await_time:float, i:int=1, change_y_target:bool=false):
	if await_time:
		await get_tree().create_timer(await_time).timeout
	var bullet :BulletPea= bullet_scene.instantiate()

	bullets.add_child(bullet)

	bullet.global_position = bullet_position.global_position
	## 有偏移的为正常发射的子弹
	if change_y_target:
		bullet.init_bullet(row_col.x + i - 1, bullet.global_position)
		bullet.change_y(ray_cast_2d_list[i].global_position.y)
	## 没有偏移的为边路补偿子弹
	else:
		bullet.init_bullet(row_col.x, bullet.global_position)
	

## 根据位置决定子弹偏移：边路补偿
func _judge_position_bullet_position():
	var plant_cell:PlantCell = get_parent()
	var hand_manager :HandManager = get_tree().current_scene.get_node("Manager/HandManager")
	if row_col.x == 0:
		bullet_border_compensation = 1
	elif row_col.x == hand_manager.plant_cells_array.size() - 1:
		bullet_border_compensation = -1
	else:
		bullet_border_compensation = 0
