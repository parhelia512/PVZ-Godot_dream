extends Node2D
class_name DancerManager


@onready var animation_player: AnimationPlayer = $AnimationPlayer
var current_animation = "armraise"  # 初始动画
## 动画的次数，前4次举手，后两次walk，6次一循环
var time_anim :int = 0
var curr_scale = Vector2(1, 1)	# 当前朝向
var custom_blend := 0.1 	# 举手动画与移动动画融合时间
var zombie_dancers: Dictionary = {-1:null, 0:null, 1:null, 2:null, 3:null}
var zombie_dancers_is_walk: Dictionary = {-1:true, 0:true, 1:true, 2:true, 3:true}
var zombie_dancers_speed_is_norm: Dictionary = {-1:true, 0:true, 1:true, 2:true, 3:true}

var animation_origin_speed :float
var animation_curr_speed :float
var zombie_manager:ZombieManager

## 需要召唤舞王的次数，第二次可以召唤,不然召唤太频繁
var time_need_call_zombie := 0
var is_hypnotized := false

func _ready() -> void:
	zombie_manager = get_tree().current_scene.get_node("Manager/ZombieManager")
	zombie_dancers[-1] = $".."
	
func start_anim() -> void:
	animation_player.set_blend_time('armraise_end', 'walk', custom_blend)
	animation_player.play(current_animation)

	

## 动画播放速度
func _init_anim_speed(animation_origin_speed, zombie:ZombieJackson):
	# 获取动画初始速度
	self.animation_origin_speed = animation_origin_speed
	animation_player.speed_scale = animation_origin_speed
	animation_curr_speed = animation_origin_speed
	
## 更新动画播放速度
func update_anim_speed_scale(animation_speed=animation_origin_speed, dancer_id:=-1, is_norm:=true):
	#如果是修改为正常播放速度
	if is_norm:
		manager_update_speed_is_norm(dancer_id, is_norm)
	else:
		animation_curr_speed = animation_speed
		animation_player.speed_scale = animation_curr_speed

		for i in zombie_dancers:
			## 伴舞继承舞王僵尸， 有可能伴舞还未召唤，此时将伴舞置为false
			if zombie_dancers[i] is ZombieJackson:
				zombie_dancers[i].manager_update_anim_speed(animation_curr_speed)

## 更新舞王和伴舞是否移动 (-1为舞王)
func manager_update_walk(dancer_id:=-1, is_walk:=true):
	zombie_dancers_is_walk[dancer_id] = is_walk
	update_all_walk()
	
func update_all_walk():
	## 是否全为true,即是否全为移动
	if zombie_dancers_is_walk.values().all(func(v): return v == true):
		for i in zombie_dancers:
			if zombie_dancers[i] is ZombieJackson:
				zombie_dancers[i].manager_update_walk(true)
	else:
		for i in zombie_dancers:
			if zombie_dancers[i] is ZombieJackson:
				zombie_dancers[i].manager_update_walk(false)


## 更新舞王和伴舞动画速度是否正常 (-1为舞王)
func manager_update_speed_is_norm(dancer_id:=-1, is_norm:=true):
	zombie_dancers_speed_is_norm[dancer_id] = is_norm
	update_all_norm_speed()
	
## 若全为正常播放速度，更新所有播放速度，伴舞死亡或伴舞减速结束时将其更新正常
func update_all_norm_speed():
	## 是否全为true,即是否全为正常速度
	if zombie_dancers_speed_is_norm.values().all(func(v): return v == true):
		animation_player.speed_scale = animation_origin_speed
		animation_curr_speed = animation_origin_speed

		for i in zombie_dancers:
			## 伴舞继承舞王僵尸， 有可能伴舞还未召唤，此时将伴舞置为false
			if zombie_dancers[i] is ZombieJackson:
				zombie_dancers[i].manager_update_anim_speed(animation_origin_speed)



## 动画结束回调函数
func _on_animation_finished(anim_name:StringName):
	# 切换到另一个动画
	# 如果举手的次数小于4次，继续举手
	if time_anim < 4:
		## 首次抬手动作判断是否召唤僵尸
		if time_anim == 0:
			#如果需要召唤伴舞僵尸,并且舞王还存在
			if judge_need_call_dance() and zombie_dancers[-1]:
				time_need_call_zombie += 1
				if time_need_call_zombie >= 2:
					time_need_call_zombie = 0
					zombie_dancers[-1].anim_play("point", curr_scale, 0, 1)
			
		time_anim += 1
		current_animation = "armraise"
		curr_scale = curr_scale * Vector2(-1, 1)
		if time_anim == 4:
			animation_player.play("armraise_end")
		else:
			animation_player.play(current_animation)
		
	elif time_anim < 6:

		time_anim += 1
		current_animation = "walk"
		animation_player.play(current_animation)
		
	else:
		time_anim = 0
		_on_animation_finished(anim_name)
		return

	for i in zombie_dancers:
		if zombie_dancers[i] is ZombieJackson:
			zombie_dancers[i].anim_play(current_animation, curr_scale, 0, 1)

## 是否需要召唤伴舞
func judge_need_call_dance():
	for i in zombie_dancers:
		if not zombie_dancers[i]:
			return true
	return false

# 获取当前播放动画的完整信息（名称、时间、速度等）
func get_current_animation_info():
	
	if animation_player.is_playing():
		# 1. 获取当前动画名称
		var anim_name = animation_player.current_animation
		
		# 2. 获取当前已播放时间（秒）
		var current_time = animation_player.get_current_animation_position()
		
		# 3. 获取当前动画总时长（秒）
		var total_time = animation_player.get_current_animation_length()
		
		# 4. 获取当前播放速度（1.0 为正常速度）
		var speed = animation_player.speed_scale
		
		# 返回整合后的信息字典
		return {
			"name": anim_name,
			"curr_scale": curr_scale,
			"current_time": current_time,
			"total_time": total_time,
			"speed": speed,
			"progress": current_time / total_time if total_time > 0 else 0.0
		}
	else:
		print("无动画播放")
		return {
			"name": 'armraise',
			"curr_scale": curr_scale,
			"current_time": 0,
			"total_time": 1,
			"speed": animation_origin_speed,
			"progress": 0
		}

## 召唤伴舞僵尸
func call_zombie_dancer():
	for i in zombie_dancers:
		if not zombie_dancers[i]:
			if i == -1:
				print("舞王不存在？有问题")
				
			var new_zombie_dancer_lane_and_postion = get_new_zombie_dancer_lane_and_postion(i, zombie_dancers[-1].lane, zombie_dancers[-1].global_position.x)
			## 如果当前位置可以生成伴舞
			if new_zombie_dancer_lane_and_postion:
				var new_zombie_dancer:ZombieDancer = zombie_manager.return_zombie(Global.ZombieType.ZombieDancer, new_zombie_dancer_lane_and_postion["lane"], is_hypnotized)
				new_zombie_dancer.lane = new_zombie_dancer_lane_and_postion["lane"]
				zombie_manager.zombies_row_node[new_zombie_dancer_lane_and_postion["lane"]].add_child(new_zombie_dancer)
				zombie_dancers[i] = new_zombie_dancer
				new_zombie_dancer.dancer_id = i
				new_zombie_dancer.global_position.x = new_zombie_dancer_lane_and_postion["global_position_x"]
				
				new_zombie_dancer.init_anim_speed_dance(animation_origin_speed, animation_curr_speed)
				new_zombie_dancer.dancer_manager = self
				
				## 如果舞王被魅惑
				if is_hypnotized:
					new_zombie_dancer.call_be_hypnotized()
					
			# 不能生成伴舞，用true填充
			else:
				zombie_dancers[i] = true
				
	## 召唤伴舞完成后更新移动
	update_all_walk()
	
func get_new_zombie_dancer_lane_and_postion(i:int, lane_Jackson:int, global_postion_x_jackson:float):
	## 上下左右顺序
	if i == 0:
		## 舞王在第一行，或者召唤行为泳池行
		if lane_Jackson == 0 or zombie_manager.zombies_row_node[lane_Jackson - 1].zombie_row_type == ZombieRow.ZombieRowType.Pool:
			return false
		return {"lane":lane_Jackson - 1, "global_position_x":global_postion_x_jackson}
	elif i == 1:
		if lane_Jackson == zombie_manager.zombies_row_node.size() - 1 or zombie_manager.zombies_row_node[lane_Jackson + 1].zombie_row_type == ZombieRow.ZombieRowType.Pool:
			return false
		return {"lane":lane_Jackson + 1, "global_position_x":global_postion_x_jackson}
	elif i == 2:
		return {"lane":lane_Jackson, "global_position_x":global_postion_x_jackson - 100}
	elif i == 3:
		return {"lane":lane_Jackson, "global_position_x":global_postion_x_jackson + 100}
	
## 舞王死后，转移父节点
func change_manager_parent():
	for i in zombie_dancers:
		## 死亡的僵尸已经置为false
		if zombie_dancers[i] is ZombieJackson:
			get_parent().remove_child(self)
			zombie_dancers[i].add_child(self)
