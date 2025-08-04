extends Node2D
class_name PlantGarden

## 植物成长状态
enum GrowthStage {
	Sprout,
	Small,
	Medium,
	Large,
	Perfect,		## 当前植物处于完美状态
}
## 需要的物品
enum NeedItem{
	Null,			## 不需要
	WateringCan,	## 水壶
	Fertilizer,		## 肥料
	BugSpray,		## 杀虫剂
	Phonograph,		## 留声机
}

const PLANTSPEECHBUBBLE = preload("res://scenes/garden/plantspeechbubble.tscn")
var plant_speech_bubble : PlantGardenSpeehBubble
## 该植物下的花盆
var flower_pot:FlowerPotGarden

@export var curr_plant_type : Global.PlantType

@onready var animation_player: AnimationPlayer = $AnimationPlayer
@onready var animation_tree: AnimationTree = $AnimationTree


#region 植物位置属性
@export_group("当前植物所处位置")
## 背景
@export var curr_garden_bg : GardenManager.GardenBgType
## 当前背景的第几页（可以有多页相同背景）
@export var curr_page := 0
## 当前页的第几个plant_cell_garden
@export var plant_cell_garden_index := 0
## 植物朝向x
var direction_x := 1.0
## 植物种植条件（默认为草地）
var curr_plant_condition:int = 2
#endregion

#region 植物状态属性
@export_group("当前植物状态")
## 是否在水族馆背景
@export var is_aquarium:= false

## 植物需求计时器
var timer:Timer
## 当前植物成长状态
@export var curr_growth_stage := GrowthStage.Small
@export var curr_need_item := NeedItem.WateringCan
## 植物需求下次更新需要的时间（短和长时间）
@export var short_time_range_need_item_next = Vector2(10,15)
## 半小时左右
@export var long_time_range_need_item_next = Vector2(2500,3500)

## 当前浇水次数
@export var curr_water_time := 0
## 最大浇水次数，每次浇水满足当前次数时重置，范围为[3,5]
@export var max_water_time := 5
## 下次更新时间
var next_update_time: String = ""  # 存储为 ISO 8601 字符串


## 创建金币的位置，为本体位置向上60像素(全局位置)
var global_position_create_coin:Vector2


## 完美植物生产金币计时器
var create_coin_timer:Timer
## 生产金币的间隔，上下波动5秒
@export var create_coin_time_cd:float = 30
#endregion


func _ready() -> void:
	## 删除方法用轨道
	remove_all_method_tracks_in_all_animations()
	
	scale.x *= direction_x
	plant_speech_bubble = PLANTSPEECHBUBBLE.instantiate()
	add_child(plant_speech_bubble)
	
		
	var ori_speed = animation_tree.get("parameters/TimeScale/scale")
	var anim_random = randf_range(0.9,1.1)
	animation_tree.set("parameters/TimeScale/scale", ori_speed * anim_random)
	
	global_position_create_coin = global_position + Vector2(0, -60)
	
	_create_need_timer()
	_create_coin_timer()
	update_growth_stage()
	_check_if_need_should_trigger()
	
## 生成需求计时器
func _create_need_timer():
	timer = Timer.new()
	timer.one_shot = true  # 只触发一次
	timer.autostart = false  # 不自动启动
	# 给 Timer 命名（便于管理）
	timer.name = "NeedTimer"
	# 将 Timer 加入到当前节点（如植物）中
	add_child(timer)
	# 连接超时信号，触发需求事件
	timer.timeout.connect(_on_need_timer_timeout)

	
## 生成完美植物生产金币计时器
func _create_coin_timer():
	create_coin_timer = Timer.new()
	create_coin_timer.one_shot = true  # 触发一次
	create_coin_timer.autostart = false  # 不自动启动
	# 给 timer 命名（便于管理）
	create_coin_timer.name = "CoinTimer"
	create_coin_timer.wait_time = create_coin_time_cd
	# 将 Timer 加入到当前节点（如植物）中
	add_child(create_coin_timer)
	# 连接超时信号，触发需求事件
	create_coin_timer.timeout.connect(_on_coin_timer_timeout)


func _on_coin_timer_timeout():
	## 下次触发
	if curr_growth_stage == GrowthStage.Perfect:
		create_coin_timer.start(create_coin_time_cd + randf_range(-5, 5))
	else:
		create_coin_timer.stop()
	Global.create_coin([0.7, 0.25, 0.05], global_position_create_coin)

	
## 检测当前是否需要触发，读档时使用
func _check_if_need_should_trigger():
	## 如果下次更新为空
	if next_update_time == "":
		_on_need_timer_timeout()
	else:		
		var now = Time.get_datetime_dict_from_system()  # 当前系统时间
		var now_unix = Time.get_unix_time_from_datetime_dict(now)
		var next_unix = Time.get_unix_time_from_datetime_string(next_update_time)

		
		if now_unix >= next_unix:
			_on_need_timer_timeout()  # 手动触发
		else:
			# 计算间隔，启动定时器
			var delta = next_unix - now_unix
			timer.wait_time = delta
			timer.start()

## 计算下次更新时间，启动计时器
func _calculate_next_need_time(time_range:Vector2):
	# 确保 timer 存在
	if not timer:
		print("Error: Timer 未初始化")
		return

	# 1. 随机生成需求等待时间
	var wait_seconds = randf_range(time_range.x, time_range.y) 
	
	# 2. 启动定时器
	timer.wait_time = wait_seconds
	timer.start()

	# 3. 保存下次更新时间（当前时间 + 等待时间）
	var now = Time.get_datetime_dict_from_system()  # 当前系统时间
	var now_unix = Time.get_unix_time_from_datetime_dict(now)
	var next_unix = now_unix + wait_seconds

	# 转换为 ISO 8601 字符串（例如："2025-07-28T12:34:56"）
	next_update_time = Time.get_datetime_string_from_unix_time(next_unix, true)


## 更新状态
func update_growth_stage():
	match curr_growth_stage:
		GrowthStage.Sprout:
			print("发芽状态")
			
		GrowthStage.Small:
			change_body_scale(Vector2(0.33 * direction_x, 0.33) )
			
		GrowthStage.Medium:
			change_body_scale(Vector2(0.66 * direction_x, 0.66))
			
		GrowthStage.Large:
			change_body_scale(Vector2(1.0 * direction_x, 1.0))
			create_coin_timer.stop()
			
		GrowthStage.Perfect:
			create_coin_timer.start(create_coin_time_cd + randf_range(-5, 5))
			
	flower_pot.plant_change_profect(curr_growth_stage == GrowthStage.Perfect)


func satisfy_need(item: NeedItem):
	# 如果植物当前没有需求，或者道具不匹配，直接返回
	if curr_need_item == NeedItem.Null or item != curr_need_item:
		return
	var is_update_growth_stage := false
	match curr_need_item:
		NeedItem.WateringCan:
			Global.create_coin([0.5, 0.5, 0.0], global_position_create_coin)
			curr_water_time += 1
			# 开启下一次需求计时
			_calculate_next_need_time(short_time_range_need_item_next)
			
		NeedItem.Fertilizer, NeedItem.BugSpray, NeedItem.Phonograph:
			if curr_growth_stage < GrowthStage.Perfect:
				up_growth_stage()
			else:
				print("不应该出现该语句，当前满足完美状态需求，")
			Global.create_coin([0.0, 0.95, 0.05], global_position_create_coin)
			Global.create_coin([0.0, 0.95, 0.05], global_position_create_coin)
			
			curr_water_time = 0
			max_water_time = randi_range(3, 5)  # 重置新的最大次数
			
			# 开启下一次需求计时
			_calculate_next_need_time(long_time_range_need_item_next)
			is_update_growth_stage = true
			
		
	curr_need_item = NeedItem.Null
	# 重置需求
	plant_speech_bubble.change_plant_need_item(curr_need_item)
	
	if is_update_growth_stage:
		update_growth_stage()

# 成长状态升级
func up_growth_stage():
	curr_growth_stage += 1
	

func change_body_scale(new_scale:Vector2):
	## 如果是原始大小，即初始化时，非生长变大
	if scale == Vector2(1,1) or scale == Vector2(-1,1): 
		## 修改大小，影子位置不变
		scale = new_scale
		
	else:
		SoundManager.play_other_SFX("wakeup")
		var tween :Tween = create_tween()
		tween.tween_property(self, "scale", new_scale, 1)


## 时间回调函数调用植物状态变化,触发该函数生成需求
func _on_need_timer_timeout():
	## 如果当前为完美状态，触发需求函数，将完美状态退化为大状态
	if curr_growth_stage == GrowthStage.Perfect:
		curr_growth_stage = GrowthStage.Large
		update_growth_stage()
		
	## 判断是否在水中
	if flower_pot.is_water:
		curr_water_time = max_water_time
	# 判断是否需要浇水
	if curr_water_time < max_water_time:
		## 需要浇水
		curr_need_item = NeedItem.WateringCan
	else:
		## 需要除浇水外的东西
		match curr_growth_stage:
			## 发芽，小，中
			GrowthStage.Sprout, GrowthStage.Small, GrowthStage.Medium:
				curr_need_item = NeedItem.Fertilizer
			## 大，完美
			GrowthStage.Large:
				curr_need_item = [NeedItem.BugSpray, NeedItem.Phonograph,].pick_random()
	
	## 更新植物需求气泡
	plant_speech_bubble.change_plant_need_item(curr_need_item)

	
func init_plant_garden(data:Dictionary, curr_garden_bg, curr_page, curr_plant_condition):
	
	direction_x = data.get("direction_x",  direction_x)
	curr_plant_type = data.get("curr_plant_type", curr_plant_type)
	self.curr_garden_bg = curr_garden_bg
	## 是否为水族馆背景，动画变化
	is_aquarium = curr_garden_bg == GardenManager.GardenBgType.Aquarium
	self.curr_page = curr_page
	self.curr_plant_condition = curr_plant_condition

	plant_cell_garden_index = data.get("plant_cell_garden_index", plant_cell_garden_index)
	curr_growth_stage = data.get("curr_growth_stage", curr_growth_stage)
	curr_need_item = data.get("curr_need_item", curr_need_item)
	curr_water_time = data.get("curr_water_time", curr_water_time)
	max_water_time = data.get("max_water_time", max_water_time)
	next_update_time = data.get("next_update_time", next_update_time)

func get_curr_plant_data() -> Dictionary:
	var data := {
		"direction_x" : direction_x,
		"curr_plant_type": curr_plant_type,
		"curr_garden_bg": curr_garden_bg,
		"curr_page": curr_page,
		"plant_cell_garden_index": plant_cell_garden_index,
		"curr_growth_stage": curr_growth_stage,
		"curr_need_item": curr_need_item,
		"curr_water_time": curr_water_time,
		"max_water_time": max_water_time,
		"next_update_time": next_update_time,
		"curr_plant_condition": curr_plant_condition
	}
	
	return data

#region 删除动画轨道中的方法调用
func remove_all_method_tracks_in_all_animations() -> void:
	for anim_name in animation_player.get_animation_list():
		remove_all_method_tracks(anim_name)

func remove_all_method_tracks(anim_name: String) -> void:
	var anim = animation_player.get_animation(anim_name)
	if anim == null:
		return

	# 从后往前删除避免索引错乱
	for i in range(anim.get_track_count() - 1, -1, -1):
		if anim.track_get_type(i) == Animation.TYPE_METHOD:
			anim.remove_track(i)

#endregion


## 激活当前植物生产金币
func activate_plant():
	if curr_growth_stage == GrowthStage.Perfect:
		create_coin_timer.start()
	
## 停止当前植物生产金币
func deactivate_plant():
	create_coin_timer.stop()
