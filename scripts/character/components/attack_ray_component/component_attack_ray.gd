extends ComponentBase
## 攻击射线检测组件,根据owner自动选择敌人层
class_name AttackRayComponent
## 每帧判断是否检测当前敌人
## 敌人进入\离开\状态变化时检测
## 敌人进入时连接状态变化函数，离开时不断开
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
## 检测区域的行属性，仅在攻击僵尸时生效
var lane:int = -1
## 是否需要判断检测敌人
var need_judge := false

## 检测区域列表
var all_ray_area:Array[Area2D]
## 检测区域的方向
var ray_area_direction:Array[Vector2]

## 外部需要的组件（攻击行为组件）连接该信号
## 检测到可攻击敌人，可以攻击信号
signal signal_can_attack
## 无可攻击敌人，取消攻击信号
signal signal_not_can_attack

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
		area_2d.collision_mask = enemy_collision_lay
		all_ray_area.append(area_2d)
		ray_area_direction.append(Vector2(cos(area_2d.rotation), sin(area_2d.rotation)))

	if lane == -1 and owner.character_init_type == Character000Base.E_CharacterInitType.IsNorm:
		printerr("lane == -1且为正常出战初始化类型")


func _physics_process(_delta):
	if need_judge:
		need_judge = false
		judge_is_have_enemy()

## 启用组件
func enable_component(is_enable_factor:E_IsEnableFactor):
	super(is_enable_factor)
	for i:int in range(get_child_count()):
		var area_2d:Area2D = get_child(i)
		area_2d.monitoring = true

	need_judge = true

## 禁用组件
func disable_component(is_enable_factor:E_IsEnableFactor):
	super(is_enable_factor)
	for node in get_children():
		if node is Area2D:
			var area_2d = node as Area2D
			area_2d.monitoring = false
	enemy_can_be_attacked = null
	signal_not_can_attack.emit()

## 敌人进入当前区域，若为同一行，当前帧进行判断是否可以攻击
func _on_area_2d_area_entered(area: Area2D, i:int) -> void:
	var enemy = area.owner
	if is_lane and lane != enemy.lane:
		return
	if enemy is Zombie000Base:
		if not enemy.signal_status_change.is_connected(_on_enemy_zombie_status_change):
			enemy.signal_status_change.connect(_on_enemy_zombie_status_change)
	need_judge = true

## 敌人离开当前射线检测区域
func _on_area_2d_area_exited(area: Area2D, i:int) -> void:
	need_judge = true

## 僵尸敌人状态变化时函数，与状态变化信号连接
func _on_enemy_zombie_status_change(zombie:Zombie000Base, curr_be_attack_status:Zombie000Base.E_BeAttackStatusZombie):
	need_judge = true

## 如果检测到可以被攻击的敌人，发射信号,保存当前敌人，return,若到最后没有检测到敌人，发射信号，重置当前敌人，return
func judge_is_have_enemy():
	#print("判定敌人")
	for ray_area in all_ray_area:
		var all_enemy_area = ray_area.get_overlapping_areas()
		for enemy_area in all_enemy_area:
			var enemy:Character000Base = enemy_area.owner
			## 先判断行属性
			if is_lane and lane != enemy.lane:
				continue
			## 如果敌人为植物
			if enemy is Plant000Base:
				var enemy_plant:Plant000Base = enemy
				## 如果当前植物可以被攻击到
				if enemy_plant.curr_be_attack_status & can_attack_plant_status:
					enemy_can_be_attacked = enemy_plant
					signal_can_attack.emit()
					return true

			## 检测到僵尸
			elif enemy is Zombie000Base:
				var enemy_zombie:Zombie000Base = enemy
				if enemy_zombie.curr_be_attack_status & can_attack_zombie_status:
					enemy_can_be_attacked = enemy_zombie
					signal_can_attack.emit()
					return true

	enemy_can_be_attacked = null
	signal_not_can_attack.emit()
	return false

## 被魅惑
func owner_be_hypno():
	enemy_collision_lay = plant_enemy_collision_lay
	disable_component(ComponentBase.E_IsEnableFactor.Hypno)
	enable_component(ComponentBase.E_IsEnableFactor.Hypno)
