extends PeaShooterSingle
class_name ThreePeater

@export var ray_cast_2d_list: Array[RayCast2D]
@export var blink_sprite_list: Array[Sprite2D]	## 控制idle状态下植物眨眼


## 边路补偿(0：正常，1：上路补偿，-1：下路补偿)
@export var bullet_border_compensation := 0

func _ready() -> void:
	super._ready()
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
		if (bullet_border_compensation == 1 and i == 1) or (bullet_border_compensation == -1 and i == 2):
			_create_bullte(0.3)
			
		else:
			_create_bullte(0, ray_cast_2d_list[i].global_position.y, true)
		
	## 攻击音效
	if throw_SFX.size() > 0:
		throw_SFX[randi() % throw_SFX.size()].play()

func _create_bullte(await_time:float, position_y_target:float=0, change_y_target:bool=false):
	if await_time:
		await get_tree().create_timer(await_time).timeout
	var bullet :BulletPea= bullet_scene.instantiate()

	bullets.add_child(bullet)
	bullet.global_position = bullet_position.global_position

	bullet.start_pos = bullet.global_position
	
	if change_y_target:
		bullet.change_y(position_y_target)


## 根据位置决定子弹偏移：边路补偿
func _judge_position_bullet_position():
	var plant_cell:PlantCell = get_parent()
	var hand_manager :HandManager = get_tree().current_scene.get_node("Manager/HandManager")
	if plant_cell.row_col.x == 0:
		bullet_border_compensation = 1
	elif plant_cell.row_col.x == hand_manager.plant_cells_array.size() - 1:
		bullet_border_compensation = -1
	else:
		bullet_border_compensation = 0
