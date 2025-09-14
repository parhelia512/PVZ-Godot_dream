extends LawnMover
class_name PoolCleaner

@onready var body: Node2D = $Body
var ori_move_speed:float

#region 游泳相关

## 碰到僵尸
var is_zombie: bool = false 

@export_group("游泳相关")
@export var is_water := false
###游泳消失的精灵图
#@export var swimming_fade : Array[Sprite2D]
###游泳出现的精灵图
#@export var swimming_appear : Array[Sprite2D]
#endregion


func _ready() -> void:
	super._ready()
	ori_move_speed = move_speed
	

func _on_area_entered(area: Area2D) -> void:
	var parent_node = area.get_parent()
	
	if parent_node is ZombieBase:  

		if lane == parent_node.lane:
			if not is_moving:
				is_moving = true
				SoundManager.play_other_SFX("pool_cleaner")
				animation_player.play("PoolCleaner_land")
				
			parent_node.be_pool_mowered_run()
			move_speed = ori_move_speed / 4
			is_zombie = true
			
	elif parent_node.name =="Pool":
		print("小推车碰撞到泳池")
		start_swim()
		
	
func _on_area_exited(area: Area2D) -> void:

	var parent_node = area.get_parent()
	if parent_node is ZombieBase:  
		pass
		
	elif parent_node.name =="Pool":
		print("小推车碰离开泳池")
		end_swim()
		
func suck_end():
	move_speed = ori_move_speed
	is_zombie = false
	
#region 水池游泳
	
func start_swim():
	# 水花
	var splash = Global.splash_pool_scenes.instantiate()
	get_parent().add_child(splash)
	splash.global_position = global_position
	is_water = true
	
func end_swim():
	# 水花
	var splash = Global.splash_pool_scenes.instantiate()
	get_parent().add_child(splash)
	splash.global_position = global_position
	is_water = false
	
#endregion
