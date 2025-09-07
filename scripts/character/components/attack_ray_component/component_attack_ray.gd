extends ComponentBase
## 攻击射线检测组件,根据owner自动选择敌人层
class_name AttackRayComponent
## 保存当前检测到的敌人
## 检测到敌人出现和消失发射信号
## **植物和僵尸通用**
## 是否使用行属性进行攻击判断
@export var is_lane:=true
## 可以攻击的敌人状态
@export_flags("1 正常", "2 悬浮", "4 地刺") var can_attack_plant_status:int = 1
@export_flags("1 正常", "2 跳跃", "4 水下", "8 空中", "16 地下") var can_attack_zombie_status:int = 1

## 植物敌人碰撞层:4(僵尸)
@export_flags_2d_physics var plant_enemy_collision_lay :int = 4
## 僵尸敌人碰撞层:2(植物) + 32(魅惑僵尸)
@export_flags_2d_physics var zomie_enemy_collision_lay :int = 2 + 32
## 敌人层
var enemy_collision_lay:int = -1:
	set(value):
		enemy_collision_lay = value
		## 更新所有检测区域的敌人mask层
		for node in get_children():
			if node is Area2D:
				var area_2d = node as Area2D
				area_2d.collision_mask = enemy_collision_lay

## 检测到的敌人
## (不能攻击是因为敌人状态不在攻击状态中，连接状态变化信号)
## 检测到的可以被攻击的一个敌人,给特殊植物\僵尸使用
var enemy_can_be_attacked :Character000Base = null
## 每个区域可以攻击的敌人二维列表
var all_ray_area_enenies_can_be_attacked:Array[Array]
## 检测区域的行属性，仅在攻击僵尸时生效
var lane:int = -1
var need_judge := false

## 外部需要的组件（攻击行为组件）连接该信号
## 检测到可攻击敌人，可以攻击信号
signal signal_can_attack
## 无可攻击敌人，取消攻击信号
signal signal_not_can_attack
var ray_area_direction:Array[Vector2]

func _ready() -> void:
	lane = owner.lane
	if owner is Zombie000Base:
		enemy_collision_lay = zomie_enemy_collision_lay
	elif owner is Plant000Base:
		enemy_collision_lay = plant_enemy_collision_lay
	else:
		push_error("组件owner不是植物或者僵尸基类角色")

	## 连接所有子节点（area2d）的信号[三线、杨桃等有多个射线area2d]
	for i:int in range(get_child_count()):
		var area_2d:Area2D = get_child(i)
		area_2d.area_entered.connect(_on_area_2d_area_entered.bind(i))
		area_2d.area_exited.connect(_on_area_2d_area_exited.bind(i))
		var new_ray_area_enenies_can_be_attacke:Array[Character000Base]=[]
		all_ray_area_enenies_can_be_attacked.append(new_ray_area_enenies_can_be_attacke)
	if lane == -1 and owner.character_init_type == Character000Base.E_CharacterInitType.IsNorm:
		printerr("lane == -1且为正常出战初始化类型")

	for ray_area2d in get_children():
		ray_area_direction.append(Vector2(cos(ray_area2d.rotation), sin(ray_area2d.rotation)))

func _physics_process(_delta):
	if need_judge:
		need_judge = false
		judge_is_have_enemy()

## 启用组件
func enable_component(is_enable_factor:E_IsEnableFactor):
	super(is_enable_factor)
	enemy_can_be_attacked = null
	for i:int in range(get_child_count()):
		var area_2d:Area2D = get_child(i)
		area_2d.monitoring = true
		# 启用后立即检查当前区域内的重叠对象
		for overlap_area in area_2d.get_overlapping_areas():
			_on_area_2d_area_entered(overlap_area, i)
	need_judge = true

## 禁用组件
func disable_component(is_enable_factor:E_IsEnableFactor):
	super(is_enable_factor)
	for node in get_children():
		if node is Area2D:
			var area_2d = node as Area2D
			area_2d.monitoring = false
	enemy_can_be_attacked = null
	for ray_area_enenies_can_be_attacked in all_ray_area_enenies_can_be_attacked:
		ray_area_enenies_can_be_attacked.clear()
	signal_not_can_attack.emit()

## 攻击射线检测区域
func _on_area_2d_area_entered(area: Area2D, i:int) -> void:
	var enemy = area.owner
	if is_lane and lane != enemy.lane:
		return
	#print_debug(owner.name, "检测到攻击敌人：", area.owner.name)
	#prints("敌人是否为僵尸：", enemy is Zombie000Base)
	#if enemy is Zombie000Base:
		#prints("敌人行属性：", enemy.lane, lane == enemy.lane)
		#prints("敌人当前被攻击状态：", enemy.curr_be_attack_status, enemy.curr_be_attack_status & can_attack_zombie_status)
		#prints("可攻击列表：", enemies_can_be_attacked, enemy not in enemies_can_be_attacked)

	if enemy is Plant000Base:
		var enemy_plant:Plant000Base = enemy
		## 如果当前植物可以被僵尸攻击到
		#prints("敌人状态:", enemy_plant.curr_be_attack_status, "攻击范围", can_attack_plant_status)
		if enemy_plant.curr_be_attack_status & can_attack_plant_status and enemy not in all_ray_area_enenies_can_be_attacked[i]:
			all_ray_area_enenies_can_be_attacked[i].append(enemy)

	#plant.be_zombie_eat(20)
	## 检测到僵尸
	elif enemy is Zombie000Base:
		var enemy_zombie:Zombie000Base = enemy
		## 连接信号僵尸状态变化函数（首次被检测到）
		if not enemy_zombie.signal_status_change.is_connected(_on_enemy_zombie_status_change.bind(i)):
			enemy_zombie.signal_status_change.connect(_on_enemy_zombie_status_change.bind(i))

		## 如果当前僵尸可以被僵尸攻击到，并且不在可以攻击列表中
		if enemy_zombie.curr_be_attack_status & can_attack_zombie_status and enemy not in all_ray_area_enenies_can_be_attacked[i]:
			all_ray_area_enenies_can_be_attacked[i].append(enemy)

	need_judge = true

## 敌人离开当前射线检测区域
func _on_area_2d_area_exited(area: Area2D, i:int) -> void:
	var enemy = area.owner
	if is_lane and lane != enemy.lane:
		return
	#if is_instance_valid(enemy):
		#print("---------------------------------------------------------------")
		#if is_instance_valid(owner):
			#print_debug(owner.name, "检测到攻击敌人离开：", enemy.name)
		#prints("敌人是否为僵尸：", enemy is Zombie000Base)
		#if enemy is Zombie000Base:
			#prints("敌人行属性：", enemy.lane, lane == enemy.lane)
			#prints("敌人当前被攻击状态：", enemy.curr_be_attack_status, enemy.curr_be_attack_status & can_attack_zombie_status)
			#prints("可攻击列表：", enemies_can_be_attacked, enemy not in enemies_can_be_attacked)
		#print("---------------------------------------------------------------")

	## 如果敌人在被攻击列表中
	if enemy in all_ray_area_enenies_can_be_attacked[i]:
		all_ray_area_enenies_can_be_attacked[i].erase(enemy)

	## 断开僵尸的状态变换信号
	if enemy is Zombie000Base:
		var enemy_zombie:Zombie000Base = enemy
		if enemy_zombie.signal_status_change.is_connected(_on_enemy_zombie_status_change.bind(i)):
			## 断开信号僵尸状态变化函数
			enemy_zombie.signal_status_change.disconnect(_on_enemy_zombie_status_change.bind(i))
	need_judge = true

func judge_is_have_enemy():
	enemy_can_be_attacked = null
	for ray_area_enenies_can_be_attacked in all_ray_area_enenies_can_be_attacked:
		if ray_area_enenies_can_be_attacked.is_empty():
			continue
		else:
			enemy_can_be_attacked = ray_area_enenies_can_be_attacked[0]
	if is_instance_valid(enemy_can_be_attacked):
		signal_can_attack.emit()
	else:
		signal_not_can_attack.emit()

## 僵尸敌人状态变化时函数，与状态变化信号连接
func _on_enemy_zombie_status_change(zombie:Zombie000Base, curr_be_attack_status:Zombie000Base.E_BeAttackStatusZombie, i:int):
	#print("僵尸状态变化")
	### 如果当前僵尸敌人可以被攻击，并且不在列表中
	if zombie.curr_be_attack_status & can_attack_zombie_status and zombie not in all_ray_area_enenies_can_be_attacked[i]:
		all_ray_area_enenies_can_be_attacked[i].append(zombie)

	## 不可以被攻击，并且在列表中
	if not zombie.curr_be_attack_status & can_attack_zombie_status and zombie in all_ray_area_enenies_can_be_attacked[i]:
		all_ray_area_enenies_can_be_attacked[i].erase(zombie)

	need_judge = true

### 刷新所有检测到的敌人
#func _refresh_detected_enemies() -> void:
	#enemies_can_be_attacked.clear()
#
	#for node in get_children():
		#if node is Area2D:
			#if not node.monitoring:
				#continue   # ⚠️ 跳过未启用检测的区域
			#for overlap_area in (node as Area2D).get_overlapping_areas():
				#var enemy = overlap_area.owner
#
				#prints(owner.name, "检测到敌人", enemy.name)
				#if enemy.is_death:
					#prints("角色已死亡", enemy.name)
					#continue
#
				#if enemy is Plant000Base:
					#var enemy_plant:Plant000Base = enemy
					#if enemy_plant.curr_be_attack_status & can_attack_plant_status and enemy not in enemies_can_be_attacked:
						#enemies_can_be_attacked.append(enemy)
#
				#elif enemy is Zombie000Base and lane == enemy.lane:
					#var enemy_zombie:Zombie000Base = enemy
					#if not enemy_zombie.signal_status_change.is_connected(_on_enemy_zombie_status_change):
						#enemy_zombie.signal_status_change.connect(_on_enemy_zombie_status_change)
#
					#if enemy_zombie.curr_be_attack_status & can_attack_zombie_status and enemy not in enemies_can_be_attacked:
						#enemies_can_be_attacked.append(enemy)
#
	## 根据检测结果发信号
	#if enemies_can_be_attacked.is_empty():
		#signal_not_can_attack.emit()
	#else:
		#signal_can_attack.emit()

## 被魅惑
func owner_be_hypno():
	enemy_collision_lay = plant_enemy_collision_lay
	disable_component(ComponentBase.E_IsEnableFactor.Hypno)
	enable_component(ComponentBase.E_IsEnableFactor.Hypno)
