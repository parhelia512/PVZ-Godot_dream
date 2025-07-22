extends ZombieBase
class_name ZombiePoleVaulter


@export var is_run := false
@export var is_jump := false
var is_jump_end := false
var is_jump_stop := false
var jump_stop_postion :Vector2

@onready var ray_cast_2d_2: RayCast2D = $RayCast2D2
@export var jump_plant_position_x : float	# 正在跳跃的植物的X值
@onready var zombie_polevaulter_outerleg_foot: Sprite2D = $Body/Zombie_polevaulter_outerleg_foot
@export var diff_all : float = 0	# 撑杆跳时的位移，
@export var jump_plant_distance: float = 70		# 跳过植物的距离


func _process(delta):
	#print(shadow.position.x)
	if is_run:
		_zombie_walk(delta)
		
		#奔跑时检测到植物
		# 每帧检查射线是否碰到植物
		if ray_cast_2d_2.is_colliding():
			if not area2d_free:
				# 设置碰撞层
				area2d.collision_layer = 16
				
				is_jump = true
				is_run = false
				is_walk = true
				walking_status = WalkingStatus.end
				var collider = ray_cast_2d_2.get_collider()
				if collider is Area2D:
				# 获取Area2D的父节点
					var parent_node = collider.get_parent()
					jump_plant_position_x = parent_node.global_position.x
				
		
	elif is_jump:
		if zombie_polevaulter_outerleg_foot.global_position.x < jump_plant_position_x - jump_plant_distance:
			var diff = zombie_polevaulter_outerleg_foot.global_position.x - (jump_plant_position_x - jump_plant_distance)
			global_position.x -= diff
			diff_all += diff
			
			
	else:
		super._process(delta)

## 跳跃被高坚果强行停止
func jump_be_stop(plant:PlantBase):
	is_jump_stop = true
	jump_stop_postion = plant.global_position

func judge_jump_be_stop():
	if is_jump_stop:
		await _jump_end()
		global_position = Vector2(jump_stop_postion.x+20, global_position.y) 
		walking_status = WalkingStatus.start
		
# 僵尸跳跃动画结束时调用结束
func _jump_end():
	if is_jump:
		is_jump_end = true
		await get_tree().process_frame
		await get_tree().process_frame
		is_jump = false
		# 设置碰撞层
		walking_status = WalkingStatus.start
		# 动画结束后将body中的所有部分都改为初始位置，并修改本体位置，保持body的位置不变
		#for body_i in body.get_children():
			#if body_i is Node2D:  # 确保节点有position属性
				#body_i.position.x += 150
		global_position.x -= 150 
			
		if area2d:
			area2d.position.x = 0
			area2d.collision_layer = 4

## 动画结束时调用
func _on_animation_tree_animation_finished(anim_name: StringName) -> void:
	#print("动画结束")
	#if anim_name == "Zombie_polevaulter_jump":
		#_jump_end()  # 在动画第一帧调用
	pass

func _play_jump_SFX():
	SoundManager.play_zombie_SFX(Global.ZombieType.ZombiePoleVaulter, "Polevault")

## 撑杆跳僵尸被炸死	
func be_bomb_death():
	animation_tree.active = false
	super.be_bomb_death()
