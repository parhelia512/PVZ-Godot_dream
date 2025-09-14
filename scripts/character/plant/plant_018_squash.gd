extends PlantBase
class_name Squash

@onready var ray_cast_2d: RayCast2D = $RayCast2D
@onready var area_2d_2: Area2D = $Area2D2

@export var is_attack: bool = false
@export var is_right:bool = true
@export var is_jump := false

## 目标僵尸位置
var target_position_x:float
## 窝瓜原始y
var ori_position_y:float

## 攻击冷却时间计时器
var attack_timer:Timer

func _ready():
	super._ready()


func _process(delta):
	# 每帧检查射线是否碰到僵尸
	if ray_cast_2d.get_collider():
		var zombie :ZombieBase = ray_cast_2d.get_collider().get_parent()
		if not is_jump:
			target_position_x = zombie.global_position.x
		if not is_attack:
			is_attack = true
			judge_zombie_right_or_left(zombie)

			
			
## 判断僵尸在自己左边还是右边
func judge_zombie_right_or_left(zombie:ZombieBase):
	SoundManager.play_plant_SFX(Global.PlantType.Squash, "SquashHmm")
	if zombie.global_position.x > global_position.x:
		is_right = true
	else:
		is_right = false
	
	area_2d.queue_free()


## 开始起跳
func jump_up_start():
	is_jump = true
	ori_position_y = global_position.y
	z_index = 415 + row_col.x * 10 
	z_as_relative = false
	
	var tween:Tween = create_tween()
	tween.tween_property(self, "global_position:x", target_position_x, 0.3).set_ease(Tween.EASE_IN)

## 跳入水中判断
func judge_jump_pool():
	var plant_cell:PlantCell = get_parent()
	## 如果地形为睡莲或者水
	if plant_cell.curr_condition & 8 or  plant_cell.curr_condition & 16:
		
		# 水花
		var splash:Splash = Global.splash_pool_scenes.instantiate()
		plant_cell.add_child(splash)
		splash.global_position = Vector2(target_position_x, plant_cell.global_position.y + 20)
		splash.z_as_relative = z_as_relative
		splash.z_index = z_index
		_plant_free()
		

func _squash_all_area_zombie():
	var areas = area_2d_2.get_overlapping_areas()
	for area in areas:
		var zombie:ZombieBase = area.get_parent()
		## 如果为同一行僵尸
		if zombie.lane == row_col.x:
			zombie.disappear_death()
	
