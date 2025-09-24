extends ComponentBase
class_name MoveComponent
## 根据ground节点移动\速度移动的组件
## 移动组件只和owner的is_walk属性、_ground节点和AnimationTree节点有关
## 移动组件要求owner必须有is_walk属性

@onready var owner_zombie: Zombie000Base = owner
@onready var _ground: Sprite2D = get_node_or_null("../Body/BodyCorrect/_ground")

## 移动方式
enum E_MoveMode {
	Ground,	## 根据ground节点移动
	Speed,	## 根据速度移动
}

## 移动方向y值修正,移动时,对应y方向的修正,屋顶斜坡使用
var move_dir_y_correct:Vector2 = Vector2.ZERO

@export var move_mode:E_MoveMode = E_MoveMode.Ground
@export var ori_speed :float = 20
var curr_speed :float = 20
var curr_speed_product :float
var curr_speed_move :float = 1

## 上一帧的ground节点位置
var _previous_ground_global_x:float
## 移动状态
enum WalkingStatus {start, walking, end}
var walking_status := WalkingStatus.end

## 是否移动
var is_move := true

## 移动因素
var move_factors:Dictionary[E_MoveFactor, bool] = {}

## 影响移动的因素、跳跃、舞王入场被卡、伴舞攻击
enum E_MoveFactor{
	IsDisable,			## 组件禁用
	IsCharacter,		## 特殊角色本身(使用该因素不能有冲突)
	IsAttack,			## 攻击
	IsBombDeath,		## 被炸死
	IsJump,				## 跳跃
	IsJacksonEnterPlant,	## 舞王入场被植物卡住
	IsDancerAttack,			## 伴舞攻击
	IsSwimingChange,		## 进入或离开泳池间隙
	IsAnimGap,				## 动画过度间隙
	IsBlover,				## 被三叶草吹走
	IsDeath,				## 停止移动的死亡时
}

signal signal_move_body_y(move_y:float)

func _ready() -> void:
	curr_speed = ori_speed

## 根据角色速度修改移动速度
func owner_update_speed(speed_product:float):
	curr_speed = ori_speed * speed_product * curr_speed_move
	curr_speed_product = speed_product

## 角色速度不变的情况下,只修改移动速度,(跳跳僵尸使用)
func update_only_move_speed(curr_speed_move:float=1):
	curr_speed = ori_speed * curr_speed_product * curr_speed_move
	self.curr_speed_move = curr_speed_move

## 更新影响移动的因素
func update_move_factor(value:bool, move_factor:E_MoveFactor):
	move_factors[move_factor] = value
	## 全为false时移动
	is_move = move_factors.values().all(func(v): return v == false)
	if is_move:
		_walking_start()

## 获取除了伴舞攻击因素之外的移动结果
func get_exclude_dancer_move_res():
	# 除了 IsDancerAttack，其他 factor 只要有 true 就不能移动
	return not move_factors.keys().any(
		func(k): return k != E_MoveFactor.IsDancerAttack and move_factors[k] == true
	)

func update_move_mode(new_move_mode:E_MoveMode):
	move_mode = new_move_mode

func _process(delta: float) -> void:
	if is_move:
		match move_mode:
			E_MoveMode.Ground:
				if walking_status == WalkingStatus.end:
					_previous_ground_global_x = _ground.global_position.x
				elif walking_status == WalkingStatus.start:
					walking_status = WalkingStatus.walking
					_previous_ground_global_x = _ground.global_position.x
				else:
					_walk()

			E_MoveMode.Speed:
				var move_x = delta * curr_speed * owner_zombie.direction_x_root
				owner_zombie.position.x -= move_x

				move_y(move_x)

func _walk():
	# 计算ground的全局坐标变化量
	var ground_global_offset = _ground.global_position.x - _previous_ground_global_x
	# 反向调整zombie的position.x以抵消ground的移动
	owner_zombie.position.x -= ground_global_offset
	# 更新记录值
	_previous_ground_global_x = _ground.global_position.x
	move_y(ground_global_offset)


## 移动y的方向
func move_y(move_x:float):
	if move_dir_y_correct == Vector2.ZERO:
		return
	else:
		signal_move_body_y.emit(-move_x / move_dir_y_correct.x * move_dir_y_correct.y)

func _walking_start():
	walking_status = WalkingStatus.start
	#print(111,"walk is start")

func _walking_end():
	walking_status = WalkingStatus.end
	#print(111,"walk is end")

func update_previous_ground_global_x():
	_previous_ground_global_x = _ground.global_position.x

## 动画结束时
func _on_animation_finished(anim_name: StringName) -> void:
	_walking_end()

### 动画开始时
#func _on_animation_tree_animation_started(anim_name: StringName) -> void:
	#_walking_start()


## 启用组件
func enable_component(is_enable_factor:E_IsEnableFactor):
	super(is_enable_factor)
	if is_enabling:
		update_move_factor(false, E_MoveFactor.IsDisable)

## 禁用组件
func disable_component(is_enable_factor:E_IsEnableFactor):
	super(is_enable_factor)
	update_move_factor(true, E_MoveFactor.IsDisable)
