extends ZombieBase
class_name ZombiePoleVaulter

@onready var _head_sprite:= [
	$Body/Anim_head1, $Body/Anim_head2, $Body/Anim_hair
]
@onready var hand_sprite:= [
	$Body/Zombie_outerarm_hand, $Body/Zombie_polevaulter_outerarm_lower
]

@onready var head_drop: Node2D = $Node2D_Head_Drop
@onready var hand_drop: Node2D = $Node2D_Hand_Drop

# 断手图片
@export var outerarm_upper2 : Texture2D

@export var is_run := false
@export var is_jump := false

@onready var ray_cast_2d_2: RayCast2D = $RayCast2D2
@export var jump_plant_position_x : float	# 正在跳跃的植物的X值
@onready var zombie_polevaulter_outerleg_foot: Sprite2D = $Body/Zombie_polevaulter_outerleg_foot
@export var diff_all : float = 0	# 撑杆跳时的位移，
@export var jump_plant_distance: float = 70		# 跳过植物的距离


func _process(delta):
	if is_run:

		if is_death:
			walking_status = WalkingStatus.end
			is_walk = false
			
		#奔跑时检测到植物
		# 每帧检查射线是否碰到植物
		elif ray_cast_2d_2.is_colliding():

			# 设置碰撞层
			$Area2D.collision_layer = 16
			
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
		

func _hp_3_stage():
	_head_fade()
	
# 头消失，
func _head_fade():
	for head_part in _head_sprite:
		head_part.visible = false
	head_drop.acitvate_it()
	
	
func _hp_2_stage():
	_hand_fade()
	
# 下半胳膊消失
func _hand_fade():
	for arm_hand_part in hand_sprite:
		arm_hand_part.visible = false
	$Body/Zombie_polevaulter_outerarm_upper.texture = outerarm_upper2

	hand_drop.acitvate_it()

# 僵尸跳跃动画结束时调用结束
func _jump_end():
	if is_jump:
		is_jump = false
		# 设置碰撞层
		$Area2D.collision_layer = 4
		walking_status = WalkingStatus.start
		# 动画结束后将body中的所有部分都改为初始位置，并修改本体位置，保持body的位置不变
		for body_i in body.get_children():
			if body_i is Node2D:  # 确保节点有position属性
				body_i.position.x += 150
		global_position.x -= 150 
		
		$Area2D.position.x = 0

## 分循环动画结束时调用
func _on_animation_tree_animation_finished(anim_name: StringName) -> void:
	if anim_name == "Zombie_polevaulter_jump":
		_jump_end()  # 在动画第一帧调用
