extends Node
class_name ZombieSpawnSystem

# 行数据类
class RowData:
	var base_weight: float 
	## 对于陆地僵尸的基础权重
	var base_weight_land: float
	## 对于水池僵尸的基础权重
	var base_weight_pool: float
	## 对于两栖僵尸的基础权重
	var base_weight_both: float
	var last_picked: int
	var second_last_picked: int
	
	func _init(weight_land: float, weight_pool: float, weight_both: float):
		base_weight = weight_land
		base_weight_land = weight_land
		base_weight_pool = weight_pool
		base_weight_both = weight_both
		last_picked = 0
		second_last_picked = 0

# 6行数据
var rows: Array[RowData] = []
var curr_type:ZombieRow.ZombieRowType = ZombieRow.ZombieRowType.Land
var total_base_weight = 0.0

# 初始化系统
func setup(initial_weights_land: Array = [], initial_weights_pool: Array = [], initial_weights_both: Array = []):
	rows.clear()
	if initial_weights_land.size() == 0:
		initial_weights_land = [1.0, 1.0, 1.0, 1.0, 1.0, 1.0]
		initial_weights_pool = [0.0, 0.0, 0.0, 0.0, 0.0, 0.0]
		initial_weights_both = [1.0, 1.0, 1.0, 1.0, 1.0, 1.0]
	
	for i in range(6):
		var weight_land = initial_weights_land[i] if i < initial_weights_land.size() else 0.0
		var weight_pool = initial_weights_pool[i] if i < initial_weights_pool.size() else 0.0
		var weight_both = initial_weights_both[i] if i < initial_weights_both.size() else 0.0
		total_base_weight += weight_land
		rows.append(RowData.new(weight_land, weight_pool, weight_both))

# 当某行被选中出怪时调用
func on_zombie_spawned(row_index: int):
	# 确保行号有效 (0-5)
	assert(row_index >= 0 and row_index < 6, "行号必须在0-5之间")
	
	# 更新所有行的历史记录
	for row in rows:
		row.last_picked += 1
		row.second_last_picked += 1
	
	# 更新被选中的行
	var picked_row = rows[row_index]
	picked_row.second_last_picked = picked_row.last_picked
	picked_row.last_picked = 0

# 计算平滑权重
func calculate_smooth_weights(zombie_row_type:ZombieRow.ZombieRowType) -> Array:

	var smooth_weights: Array = []
	
	# 计算总基础权重
	if curr_type != zombie_row_type:
		
		total_base_weight = 0.0
		curr_type = zombie_row_type
		for row in rows:
			match zombie_row_type:
				ZombieRow.ZombieRowType.Land:
					row.base_weight = row.base_weight_land
				ZombieRow.ZombieRowType.Pool:
					row.base_weight = row.base_weight_pool
				ZombieRow.ZombieRowType.Both:
					row.base_weight = row.base_weight_both
			total_base_weight += row.base_weight
	# 计算每行的平滑权重
	for row in rows:
		if row.base_weight <= 0 or total_base_weight <= 0:
			smooth_weights.append(0.0)
			continue
			
		var weight_p = row.base_weight / total_base_weight
		
		# 计算影响因子
		var p_last = (6.0 * row.last_picked * weight_p + 6.0 * weight_p - 3.0) / 4.0
		var p_second_last = (row.second_last_picked * weight_p + weight_p - 1.0) / 4.0
		
		# 计算并限制平滑权重
		var combined = p_last + p_second_last
		combined = clamp(combined, 0.01, 100.0)
		var smooth_weight = weight_p * combined
		
		smooth_weights.append(smooth_weight)
	
	return smooth_weights

# 选择下一个出怪行
func select_spawn_row(zombie_row_type:ZombieRow.ZombieRowType)  -> int:
	var smooth_weights = calculate_smooth_weights(zombie_row_type)
	var total_smooth_weight = 0.0
	
	# 计算总平滑权重
	for w in smooth_weights:
		total_smooth_weight += w
	
	# 特殊情况处理：所有行权重为0时选择第5行(游戏中的第6行)
	if total_smooth_weight <= 0:
		return 5
	
	# 生成随机数
	var rand_num = randf_range(0.0, total_smooth_weight)
	var cumulative_weight = 0.0
	
	# 选择行
	for i in range(6):
		cumulative_weight += smooth_weights[i]
		if cumulative_weight >= rand_num:
			return i  # 返回0-5的行索引
	
	# 如果前5行都没选中，默认选择第5行(游戏中的第6行)
	return 5

# 获取行选择概率(用于调试)
func get_row_probabilities() -> Array:
	var smooth_weights = calculate_smooth_weights(0)
	var total = 0.0
	for w in smooth_weights:
		total += w
	
	var probabilities = []
	for w in smooth_weights:
		probabilities.append(w / total if total > 0 else 0.0)
	
	return probabilities

## 示例用法
#func _ready():
	## 初始化系统，可以传入自定义权重
	#setup([1.0, 1.0, 0.0, 0.0, 1.0, 1.0], [0.0,0.0,1.0,1.0,0.0,0.0],[1.0, 1.0, 1.0, 1.0, 1.0, 1.0])
	#var res = {1:0, 2:0, 3:0, 4:0, 5:0, 6:0}
	## 模拟10次出怪
	#for i in range(50):
		#var selected_row = select_spawn_row(ZombieRow.ZombieRowType.Both)
		#print("第%d次出怪: 第%d行" % [i+1, selected_row+1])
		#print("当前概率分布: ", get_row_probabilities())
		#on_zombie_spawned(selected_row)
		#res[selected_row+1] += 1
	#print(res)
