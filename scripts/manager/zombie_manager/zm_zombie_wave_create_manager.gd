extends Node
## 僵尸波次生成管理器
class_name ZombieWaveCreateManager

@onready var zombie_manager: ZombieManager = %ZombieManager
## 僵尸选行系统
@onready var zombie_choose_row_system: ZombieChooseRowSystem = %ZombieChooseRowSystem

## 定义每个僵尸的战力值
const zombie_power = {
	Global.ZombieType.ZombieNorm: 1,		# 普僵战力
	Global.ZombieType.ZombieFlag: 1,		# 旗帜战力
	Global.ZombieType.ZombieCone: 2,		# 路障战力
	Global.ZombieType.ZombiePoleVaulter: 2,	# 撑杆战力
	Global.ZombieType.ZombieBucket: 4,		# 铁桶战力

	Global.ZombieType.ZombiePaper: 4,		# 读报战力
	Global.ZombieType.ZombieScreenDoor: 4,	# 铁门战力
	Global.ZombieType.ZombieFootball: 4,	# 橄榄球战力
	Global.ZombieType.ZombieJackson: 4,		# 舞王战力
	Global.ZombieType.ZombieDancer: 1,		# 伴舞权重

	Global.ZombieType.ZombieSnorkle: 2,		# 潜水
	Global.ZombieType.ZombieZamboni: 4,		# 冰车
	Global.ZombieType.ZombieBobsled: 4,		# 滑雪四兄弟
	Global.ZombieType.ZombieDolphinrider: 3,# 海豚僵尸
}

## 创建 zombie_weights 字典，存储初始权重,普僵权重会修改，
var zombie_weights = {
	Global.ZombieType.ZombieNorm: 4000,			# 普僵权重
	Global.ZombieType.ZombieFlag: 0,			# 旗帜权重
	Global.ZombieType.ZombieCone: 4000,			# 路障权重
	Global.ZombieType.ZombiePoleVaulter: 2000,	# 撑杆权重
	Global.ZombieType.ZombieBucket: 3000,		# 铁桶权重

	Global.ZombieType.ZombiePaper: 3000,		# 读报权重
	Global.ZombieType.ZombieScreenDoor: 3000,	# 铁门权重
	Global.ZombieType.ZombieFootball: 3000,		# 橄榄球权重
	Global.ZombieType.ZombieJackson: 3000,		# 舞王权重
	Global.ZombieType.ZombieDancer: 4000,		# 舞王权重

	Global.ZombieType.ZombieSnorkle: 3000,		# 潜水
	Global.ZombieType.ZombieZamboni: 3000,		# 冰车
	Global.ZombieType.ZombieBobsled: 3000,		# 滑雪四兄弟
	Global.ZombieType.ZombieDolphinrider: 3000,	# 海豚僵尸
}

## 每波最大僵尸数量
@export var max_zombies_per_wave = 50
## 出怪倍率
var zombie_multy := 1
## 僵尸刷新类型
var zombie_refresh_types:Array[Global.ZombieType]
## 刷新类型最小战力
var min_power:=100
## 当前所有可能出怪僵尸权重上限和,每波修改
var curr_zombie_weight_upper_limit :int
## 当前波次生成的僵尸
var wave_all_zombies:Array[Zombie000Base]

## 创建僵尸信号，发给僵尸管理器创建僵尸
signal signal_create_one_zombie_in_wave

## 初始化创建波次僵尸管理器
func init_zombie_wave_create_manager(game_para:ResourceLevelData):
	self.zombie_multy = game_para.zombie_multy
	self.zombie_refresh_types = game_para.zombie_refresh_types
	for zombie_type in self.zombie_refresh_types:
		if min_power > zombie_power[zombie_type]:
			min_power =  zombie_power[zombie_type]

	zombie_choose_row_system.init_zombie_choose_row_system()

#region #TODO:珊瑚僵尸
## 最后一大波珊瑚僵尸
#func spawn_sea_weed_zombies(lane_pool:Array[int]):
	#var zombie_type_sea_weed_list :Array= [Global.ZombieType.ZombieNorm, Global.ZombieType.ZombieCone, Global.ZombieType.ZombieBucket]
	#for i in range(3):
		#var zombie_type:Global.ZombieType = zombie_type_sea_weed_list.pick_random()
		#var lane :int = lane_pool.pick_random()
		#var new_zombie :Zombie000Base= return_zombie(zombie_type, lane)
		#new_zombie.curr_zombie_row_type = zombies_row_node[lane].zombie_row_type
		#new_zombie.lane = lane
		#new_zombie.is_sea_weed_zombie = true
		#zombies_row_node[lane].add_child(new_zombie)
		#new_zombie.global_position.y = zombies_row_node[lane].get_node("ZombieCreatePosition").global_position.y
		#new_zombie.global_position.x = randf_range(500, 750)
		#new_zombie.sea_weed_init()
		#
		#new_zombie.sea_weed_appear()
#endregion

#region 创建当前波次僵尸
## 创建当前波僵尸
func create_curr_wave_all_zombies(wave:int, is_big_wave:bool):
	## 获取当前波僵尸生成列表
	var wave_spawn :Array[Global.ZombieType] = create_curr_wave_zombie_list(wave, is_big_wave)
	## 特殊基础权重,若有雪橇车僵尸,更新该权重
	var special_base_weight:Array[float] = []
	wave_all_zombies.clear()
	## 当前波次僵尸数据
	var curr_wave_zombie_date:Array[Dictionary]

	for i in wave_spawn.size():
		var zombie_type : Global.ZombieType = wave_spawn[i]
		var lane :int = -1
		## 雪橇车僵尸
		if zombie_type == Global.ZombieType.ZombieBobsled:
			## 计算冰道权重
			if special_base_weight.is_empty():
				for row_ice_road:Array[IceRoad] in MainGameDate.all_ice_roads:
					if row_ice_road.is_empty():
						special_base_weight.append(0)
					else:
						special_base_weight.append(1)
				print(special_base_weight)
			## 如果没有冰道
			if GlobalUtils.sum_arr(special_base_weight) == 0:
				zombie_type = Global.ZombieType.ZombieZamboni
				lane = zombie_choose_row_system.select_spawn_row(Global.ZombieInfo[zombie_type][Global.ZombieInfoAttribute.ZombieRowType])
			else:
				lane = zombie_choose_row_system.select_spawn_row(Global.ZombieInfo[zombie_type][Global.ZombieInfoAttribute.ZombieRowType], special_base_weight)
		else:
			lane = zombie_choose_row_system.select_spawn_row(Global.ZombieInfo[zombie_type][Global.ZombieInfoAttribute.ZombieRowType])
		curr_wave_zombie_date.append(
			{
				"zombie_type":zombie_type,
				"lane":lane,
			}
		)
	for curr_wave_one_zombie_date in curr_wave_zombie_date:
		var zombie = wave_create_zombie(
			curr_wave_one_zombie_date["zombie_type"],
			curr_wave_one_zombie_date["lane"],
			wave
		)
		wave_all_zombies.append(zombie)

	return wave_all_zombies


## 生成波次僵尸
func wave_create_zombie(
	zombie_type:Global.ZombieType,
	lane:int, 	## 僵尸行
	curr_wave:int,		## 僵尸波次
):
	var zombie_parent = MainGameDate.all_zombie_rows[lane]
	var zombie_init_type = Character000Base.E_CharacterInitType.IsNorm
	var zombie_pos = MainGameDate.all_zombie_rows[lane].zombie_create_position.position + Vector2(randf_range(-10, 10), 0)

	var zombie = zombie_manager.create_norm_zombie(zombie_type,zombie_parent,zombie_init_type,lane,curr_wave,zombie_pos)

	return zombie

#region 创建当前波僵尸生成列表
## 创建当前波僵尸生成列表
func create_curr_wave_zombie_list(wave:int, is_big_wave:bool):
	## 计算当前波僵尸战力上限
	var curr_wave_power_limit = calculate_wave_power_limit(wave, is_big_wave)
	## 更新僵尸权重上限
	update_curr_zombie_weight_upper_limit(wave)
	## 获取当前波的生成僵尸列表
	var wave_spawn :Array[Global.ZombieType] = get_curr_wave_zombie_list(wave, is_big_wave, curr_wave_power_limit)

	return wave_spawn

## 计算每波的战力上限
func calculate_wave_power_limit(wave:int, is_big_wave: bool) -> int:
	## x从0开始
	## 计算战力上限 = y=int(x/3)+1
	var base_power_limit:int = wave / 3 + 1
	## 如果是大波，战力上限是原战力上限的2.5倍
	if is_big_wave:
		return int(base_power_limit * 2.5) * zombie_multy

	return base_power_limit * zombie_multy

## 计算当前波僵尸权重上限
func update_curr_zombie_weight_upper_limit(wave:int):
	## 如果是第0波
	if wave == 0:
		curr_zombie_weight_upper_limit = 0
		# 计算所有可能僵尸的权重总和
		for zombie_type in zombie_refresh_types:
			curr_zombie_weight_upper_limit += zombie_weights[zombie_type]
	elif wave < 4:
		pass
	elif wave < 26:
		_update_weights(wave)
		curr_zombie_weight_upper_limit = 0
		# 计算所有可能僵尸的权重总和
		for zombie_type in zombie_refresh_types:
			curr_zombie_weight_upper_limit += zombie_weights[zombie_type]
	else:
		pass

## 更新僵尸权重
func _update_weights(wave: int):
	# 普通僵尸权重调整逻辑
	if wave >= 5:
		var norm_weight = 4000 - (wave - 4) * 180
		if wave >= 25:
			norm_weight = 400  # 当轮次达到25时，普通僵尸权重固定为400
		zombie_weights[Global.ZombieType.ZombieNorm] = norm_weight

	# 路障僵尸权重调整逻辑
	if wave >= 5:
		var cone_weight = 4000 - (wave - 4) * 150
		if wave >= 25:
			cone_weight = 1000  # 当轮次达到25时，路障僵尸权重固定为1000
		zombie_weights[Global.ZombieType.ZombieCone] = cone_weight

## 获取当前波僵尸列表
func get_curr_wave_zombie_list(wave:int, is_big_wave: bool, curr_wave_power_limit:int) ->Array[Global.ZombieType]:
	## 当前波的僵尸列表
	var wave_spawn :Array[Global.ZombieType]= []
	## 目前总战力
	var total_power = 0
	## 当前空隙位置
	var curr_spare_slot = self.max_zombies_per_wave

	## 如果是大波，先刷新特殊僵尸
	if is_big_wave:
		## 第一个旗帜僵尸
		wave_spawn.append(Global.ZombieType.ZombieFlag)
		total_power += zombie_power[Global.ZombieType.ZombieFlag]
		curr_spare_slot -= 1

		# 第一次大波（第10波），刷新4个普通僵尸
		if wave == 9:
			for i in range(4):
				wave_spawn.append(Global.ZombieType.ZombieNorm)
				total_power += zombie_power[Global.ZombieType.ZombieNorm]
				curr_spare_slot -= 1
		# 之后的大波（第20波、30波...），刷新8个普通僵尸
		else:
			for i in range(8):
				wave_spawn.append(Global.ZombieType.ZombieNorm)
				total_power += zombie_power[Global.ZombieType.ZombieNorm]
				curr_spare_slot -= 1

	# 生成剩余僵尸，直到总战力符合当前战力上限
	while curr_spare_slot > 0 and total_power < curr_wave_power_limit:
		var selected_zombie = _get_random_zombie_based_on_weight()
		var zombie_power_value = zombie_power[selected_zombie]
		# 检查如果加上该僵尸的战力后超过当前波的战力上限，重新选择
		if total_power + zombie_power_value <= curr_wave_power_limit:
			wave_spawn.append(selected_zombie)
			total_power += zombie_power_value
			curr_spare_slot -= 1
		elif curr_wave_power_limit - total_power < min_power:
			for i in range(curr_wave_power_limit - total_power):
				wave_spawn.append(Global.ZombieType.ZombieNorm)
				total_power += zombie_power[Global.ZombieType.ZombieNorm]
				curr_spare_slot -= 1
			continue
		else:
			continue

	return wave_spawn

## 获取根据权重选择的僵尸
func _get_random_zombie_based_on_weight() -> int:
	## 基于统一的刷新种类随机选择僵尸
	var cumulative_weight = 0
	var max_weight = 0

	# 计算所有可能僵尸的权重总和
	for zombie_type in zombie_refresh_types:
		max_weight += zombie_weights[zombie_type]

	var random_value = randi_range(0, max_weight)  # 使用动态计算的最大权重

	for zombie_type in zombie_refresh_types:
		cumulative_weight += zombie_weights[zombie_type]

		if random_value < cumulative_weight:
			return zombie_type  # 返回选中的僵尸类型

	## 如果没有选中，默认返回普通僵尸
	return Global.ZombieType.ZombieNorm

#endregion

#endregion
